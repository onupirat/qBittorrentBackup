# qBittorrent Backup and Restore App
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Default paths
$qbtConfigPath = "$env:APPDATA\qBittorrent"
$qbtDataPath = "$env:LOCALAPPDATA\qBittorrent"
$backupPath = "$env:USERPROFILE\Desktop\qBittorrentBackup"

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "qBittorrentBackup"
$form.Size = New-Object System.Drawing.Size(636, 180)
$form.StartPosition = "CenterScreen"

# Backup Panel
$backupPanel = New-Object System.Windows.Forms.Panel
$backupPanel.Location = New-Object System.Drawing.Point(20, 20)
$backupPanel.Size = New-Object System.Drawing.Size(280, 100)
$backupPanel.BorderStyle = "FixedSingle"

# Backup Destination
$backupDestLabel = New-Object System.Windows.Forms.Label
$backupDestLabel.Location = New-Object System.Drawing.Point(10, 10)
$backupDestLabel.Size = New-Object System.Drawing.Size(120, 20)
$backupDestLabel.Text = "Backup Destination"
$backupPanel.Controls.Add($backupDestLabel)

$backupDestText = New-Object System.Windows.Forms.TextBox
$backupDestText.Location = New-Object System.Drawing.Point(10, 30)
$backupDestText.Size = New-Object System.Drawing.Size(180, 20)
$backupDestText.Text = "$env:USERPROFILE\Desktop\qBittorrentBackup"
$backupPanel.Controls.Add($backupDestText)

$browseDestButton = New-Object System.Windows.Forms.Button
$browseDestButton.Location = New-Object System.Drawing.Point(195, 30)
$browseDestButton.Size = New-Object System.Drawing.Size(60, 20)
$browseDestButton.Text = "Browse"
$backupPanel.Controls.Add($browseDestButton)

# Start Backup Button
$startBackupButton = New-Object System.Windows.Forms.Button
$startBackupButton.Location = New-Object System.Drawing.Point(70, 60)
$startBackupButton.Size = New-Object System.Drawing.Size(140, 30)
$startBackupButton.Text = "Start Backup"
$backupPanel.Controls.Add($startBackupButton)

# Running Indicator
$runningLabel = New-Object System.Windows.Forms.Label
$runningLabel.Location = New-Object System.Drawing.Point(130, 10)
$runningLabel.Size = New-Object System.Drawing.Size(240, 20)
$runningLabel.Text = ""
$backupPanel.Controls.Add($runningLabel)

# Restore Panel
$restorePanel = New-Object System.Windows.Forms.Panel
$restorePanel.Location = New-Object System.Drawing.Point(320, 20)
$restorePanel.Size = New-Object System.Drawing.Size(280, 100)
$restorePanel.BorderStyle = "FixedSingle"

# Select Backup Folder
$selectBackupLabel = New-Object System.Windows.Forms.Label
$selectBackupLabel.Location = New-Object System.Drawing.Point(10, 10)
$selectBackupLabel.Size = New-Object System.Drawing.Size(120, 20)
$selectBackupLabel.Text = "Select Backup Folder"
$restorePanel.Controls.Add($selectBackupLabel)

$selectBackupText = New-Object System.Windows.Forms.TextBox
$selectBackupText.Location = New-Object System.Drawing.Point(10, 30)
$selectBackupText.Size = New-Object System.Drawing.Size(180, 20)
$selectBackupText.Text = "Select a folder to see options"
$restorePanel.Controls.Add($selectBackupText)

$selectBackupButton = New-Object System.Windows.Forms.Button
$selectBackupButton.Location = New-Object System.Drawing.Point(195, 30)
$selectBackupButton.Size = New-Object System.Drawing.Size(60, 20)
$selectBackupButton.Text = "Select"
$restorePanel.Controls.Add($selectBackupButton)

# Restore Button
$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Location = New-Object System.Drawing.Point(90, 60)
$restoreButton.Size = New-Object System.Drawing.Size(140, 30)
$restoreButton.Text = "Restore Backup"
$restorePanel.Controls.Add($restoreButton)

# Backup Button Action
$startBackupButton.Add_Click({
    $runningLabel.Text = "Backup in progress..."
    $runningLabel.ForeColor = [System.Drawing.Color]::Red # Set text color to red
    $form.Refresh()
    try {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = Join-Path $backupDestText.Text "qBittorrent_Backup_$timestamp"
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        Copy-Item -Path $qbtConfigPath -Destination (Join-Path $backupDir "qBittorrent_Config") -Recurse -Force
        Copy-Item -Path $qbtDataPath -Destination (Join-Path $backupDir "qBittorrent_Data") -Recurse -Force
        [System.Windows.Forms.MessageBox]::Show("Backup completed to $backupDir", "Success")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Backup failed: $_", "Error")
    }
    $runningLabel.Text = ""
    $form.Refresh()
})

# Restore Button Action
$restoreButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select qBittorrent backup folder"
    $folderBrowser.SelectedPath = $backupPath

    if ($folderBrowser.ShowDialog() -eq "OK") {
        $selectedBackup = $folderBrowser.SelectedPath
        $selectBackupText.Text = $selectedBackup
        try {
            Copy-Item -Path "$selectedBackup\qBittorrent_Config\*" -Destination $qbtConfigPath -Recurse -Force
            Copy-Item -Path "$selectedBackup\qBittorrent_Data\*" -Destination $qbtDataPath -Recurse -Force
            [System.Windows.Forms.MessageBox]::Show("Restore completed from $selectedBackup", "Success")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Restore failed: $_", "Error")
        }
    }
})

# Browse Buttons Action
$browseDestButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.SelectedPath = $backupDestText.Text
    if ($folderBrowser.ShowDialog() -eq "OK") { $backupDestText.Text = $folderBrowser.SelectedPath }
})
$selectBackupButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.SelectedPath = $selectBackupText.Text
    if ($folderBrowser.ShowDialog() -eq "OK") { $selectBackupText.Text = $folderBrowser.SelectedPath }
})

# Add panels to form
$form.Controls.Add($backupPanel)
$form.Controls.Add($restorePanel)

# Show form
$form.ShowDialog()
