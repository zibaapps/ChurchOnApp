# git_workflow.ps1
# Automated git branch syncing and merging script for your ChurchOnApp repo

param (
    [string]$RepoPath = "C:\Users\User\ChurchOnApp\church_on_app"
)

function Run-GitCommand {
    param([string]$command)

    Write-Host "`nRunning: git $command"
    cd $RepoPath
    git $command
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Command failed: git $command"
        Write-Host "Please resolve issues manually and rerun the script."
        exit 1
    }
}

# Step 1: Sync main into feature and test branches
Write-Host "Step 1: Syncing main branch into feature and test branches..."

# Feature branch sync
Run-GitCommand "checkout build-church-on-app-with-all-features-1463"
Run-GitCommand "fetch origin"
Run-GitCommand "pull origin main"

# Test branch sync
Run-GitCommand "checkout Church-On-App-with-Cursor"
Run-GitCommand "fetch origin"
Run-GitCommand "pull origin main"

# Step 2: Merge feature branch into test branch
Write-Host "Step 2: Merging feature branch into test branch..."
Run-GitCommand "checkout Church-On-App-with-Cursor"
Run-GitCommand "fetch origin"
Run-GitCommand "pull origin Church-On-App-with-Cursor"
Run-GitCommand "merge build-church-on-app-with-all-features-1463"

# Step 3: Merge test branch into main branch
Write-Host "Step 3: Merging test branch into main branch..."
Run-GitCommand "checkout main"
Run-GitCommand "fetch origin"
Run-GitCommand "pull origin main"
Run-GitCommand "merge Church-On-App-with-Cursor"

# Step 4: Push all branches
Write-Host "Step 4: Pushing all branches to origin..."
Run-GitCommand "push origin build-church-on-app-with-all-features-1463"
Run-GitCommand "push origin Church-On-App-with-Cursor"
Run-GitCommand "push origin main"

Write-Host "`nWorkflow complete! If there were conflicts, please resolve manually."
