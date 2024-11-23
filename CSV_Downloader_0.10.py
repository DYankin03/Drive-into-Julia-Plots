
import os
import argparse
import googleapiclient.discovery
from google.oauth2.service_account import Credentials
from googleapiclient.http import MediaIoBaseDownload
import io
import pandas as pd

def get_file_ids_in_folder(service, folder_id):
    """Retrieves a list of file IDs within a specified folder.

    Args:
        service: A Google Drive API service object.
        folder_id: The ID of the folder to search.

    Returns:
        A list of file IDs.
    """
    page_token = None
    file_ids = []
    while True:
        response = service.files().list(
            q=f"'{folder_id}' in parents and mimeType='application/vnd.google-apps.spreadsheet'",
            spaces='drive',
            fields='nextPageToken, files(id, name)',
            pageToken=page_token
        ).execute()

        files = response.get('files', [])
        if not files:
            print("No files found.")
        for file in files:
            print(f"Found file: {file['name']} ({file['id']})")
            file_ids.append(file['id'])

        page_token = response.get('nextPageToken', None)
        if not page_token:
            break

    return file_ids


def main(folder_id, json_creds, output_dir):
    # Expand user directory
    json_creds = os.path.expanduser(json_creds)
    output_dir = os.path.expanduser(output_dir)

    # Authenticate
    creds = Credentials.from_service_account_file(json_creds)
    service = googleapiclient.discovery.build('drive', 'v3', credentials=creds)

    # Get the file IDs
    file_ids = get_file_ids_in_folder(service, folder_id)
    print(f"File IDs: {file_ids}")

    # Specify the download location
    os.makedirs(output_dir, exist_ok=True)

    # Download the file
    for file_id in file_ids:
        # Export the file as an Excel file
        request = service.files().export_media(fileId=file_id, mimeType='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        while not done:
            status, done = downloader.next_chunk()
            print(f'Download {int(status.progress() * 100)}%.')

        # Convert to CSV (e.g., using pandas)
        fh.seek(0)  # Reset the file handle position to the beginning
        df = pd.read_excel(fh)
        csv_path = os.path.join(output_dir, f'{file_id}.csv')
        df.to_csv(csv_path, index=False)
        print(f'File saved to {csv_path}')
        
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Download Google Sheets files from a specified folder.')
    parser.add_argument('-f', '--folder_id', type=str, help='The ID of the folder to search for Google Sheets files.')
    parser.add_argument('-o', '--ouput_dir', type=str, help='The output directory for the downloaded files.')
    parser.add_argument('-c', '--credential_json_dir', type=str, help='The directory of Google drive authentication credentials.')
    args = parser.parse_args()
    print(args)
    main(args.folder_id, args.credential_json_dir, args.ouput_dir)