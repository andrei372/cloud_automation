# Introduction

Repo for cloud deployments and automation

Within the puppet_env folder python scripts deploy a Puppet Master\Client environment to GCP

# How to run

	1. Create a service account on our Google Cloud platform with the right permissions
		https://cloud.google.com/iam/docs/creating-managing-service-accounts
		
	2. Create a json key that allows remote deployments under the service account
		https://cloud.google.com/iam/docs/creating-managing-service-account-keys
		
	3. Open a terminal window and log into your Google Cloud account
		"gcloud auth login"
	
	4. Under Windows 
		From a command prompt run "python.exe .\api_app_main.py"
	   Under Linux
	    From a command prompt run "python3 .\api_app_main.py"  (make sure that all .py files are executable; execute "chmod +x *.py")