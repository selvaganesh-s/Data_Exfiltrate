# Define the path and encryption key
$path = "C:\Users\explorer\Documents\Encrypt"
$encryptionKey = "JWMUgn6nR/qt77ia9VzoXgtmGAU3m58+x2oabOzIDN8=" # 32-byte key in Base64 format

# Decode the key from Base64 to bytes
$keyBytes = [System.Convert]::FromBase64String($encryptionKey)

# Check key length
$keyLength = $keyBytes.Length
if ($keyLength -ne 32) {
    throw "The key must be 32 bytes long for AES-256 encryption. Current key length: $($keyLength) bytes."
}

# Function to decrypt data
function Decrypt-Data {
    param (
        [byte[]]$data,
        [byte[]]$key
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    # Extract the IV from the start of the data
    $iv = $data[0..15]
    $encryptedData = $data[16..($data.Length - 1)]

    $aes.IV = $iv

    $decryptor = $aes.CreateDecryptor()

    $decryptedData = $decryptor.TransformFinalBlock($encryptedData, 0, $encryptedData.Length)
    $aes.Dispose()

    return $decryptedData
}

# Process each encrypted file in the directory
Get-ChildItem -Path $path -File | Where-Object { $_.Extension -eq ".enc" } | ForEach-Object {
    $filePath = $_.FullName
    $fileName = $_.Name
    $originalFileName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $newFilePath = Join-Path -Path $path -ChildPath $originalFileName

    Write-Host "Processing file: $filePath"
    Write-Host "Decrypting and saving to: $newFilePath"

    try {
        # Read the encrypted file content
        $fileContent = [System.IO.File]::ReadAllBytes($filePath)
        
        # Decrypt the content
        $decryptedContent = Decrypt-Data -data $fileContent -key $keyBytes
        
        # Create a new file with the decrypted content
        [System.IO.File]::WriteAllBytes($newFilePath, $decryptedContent)

        # Remove the encrypted file
        Remove-Item -Path $filePath -Force

        Write-Host "File decrypted and restored successfully: $newFilePath"
    } catch {
        Write-Host ("Error processing file " + $filePath + ": " + $_.Exception.Message)
    }
}

Write-Host "Decryption and restoration completed."
