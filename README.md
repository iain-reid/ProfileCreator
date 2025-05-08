# ProfileCreator

A Swift-based service for creating and signing iOS configuration profiles.

## Setup

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
CERTIFICATE_PATH=Certificates/profile_creator.p12
CERTIFICATE_PASSWORD=development
```

### Development Certificate

For development purposes, you can create a self-signed certificate using the provided script:

```bash
# Make the script executable
chmod +x Scripts/create_profile_certificate.sh

# Run the script
./Scripts/create_profile_certificate.sh
```

This will create a development certificate at `Certificates/profile_creator.p12` with the password "development".

### Production Certificate

For production use, you'll need to obtain a proper certificate from Apple. You can do this through:

1. Apple Developer Program (https://developer.apple.com)
2. Apple Business Manager (https://business.apple.com)
3. Apple School Manager (https://school.apple.com)

Once you have your production certificate:
1. Convert it to PKCS12 format if it isn't already
2. Place it in the `Certificates` directory
3. Update the `CERTIFICATE_PATH` and `CERTIFICATE_PASSWORD` in your `.env` file

## Running the Service

```bash
swift run
```

The service will start on `http://localhost:8080`.

## Testing

### Uploading a Profile

Use curl to upload a mobile configuration file:

```bash
curl -X POST -F "file=@Resources/test.mobileconfig" http://localhost:8080/api/mobileconfig/upload
```

The response will include a download URL:
```json
{
    "status": "success",
    "download_url": "/uploads/UUID.mobileconfig"
}
```

### Installing on iOS Device

1. Make sure your iOS device is on the same network as the server
2. Find your computer's local IP address:
   ```bash
   ipconfig getifaddr en0  # On macOS
   ```
3. Construct the full URL using your computer's IP:
   ```
   http://YOUR_IP:8080/uploads/UUID.mobileconfig
   ```
   For example: `http://192.168.1.100:8080/uploads/UUID.mobileconfig`

4. Open this URL in Safari on your iOS device
5. Follow the prompts to install the profile

## Troubleshooting

- If you get a "port in use" error, find and kill the existing process:
  ```bash
  lsof -i :8080
  kill <PID>
  ```
- If the profile fails to install, check the server logs for signing errors
- Make sure your iOS device can reach the server's IP address on port 8080 