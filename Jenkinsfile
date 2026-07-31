pipeline {

    agent any

    options {
        ansiColor('xterm')
        timestamps()
    }

    parameters {
        choice(
            name: 'TERRAFORM_ENV',
            choices: [
                'dev',
                'prod'
            ],
            description: 'Terraform environment to deploy'
        )
    }


    environment {
        TERRAFORM_PATH = "terraform/environments/${params.TERRAFORM_ENV}"
    }


    stages {

        stage('Checkout') {
            steps {
                git(
                    branch: 'develop',
                    url: 'https://github.com/ElMoix/azure-infrastructure-lab.git',
                    credentialsId: 'github-token'
                )
            }
        }


        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_PATH}") {
                    sh 'terraform init'
                }
            }
        }


        stage('Terraform Validate') {
            steps {
                dir("${TERRAFORM_PATH}") {
                    sh 'terraform validate'
                }
            }
        }


	stage('Checkov') {
    	    steps {
        	dir("${TERRAFORM_PATH}") {
            	    sh '''
                      checkov \
                      -d . \
                      --framework terraform \
                      --soft-fail
            	    '''
        	}
    	    }
	}

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_PATH}") {

                    withCredentials([
                        azureServicePrincipal(
                            credentialsId: 'azure-service-principal',
                            subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                            clientIdVariable: 'ARM_CLIENT_ID',
                            clientSecretVariable: 'ARM_CLIENT_SECRET',
                            tenantIdVariable: 'ARM_TENANT_ID'
                        )
                    ]) {

                        sh '''
                            terraform plan -out=tfplan
                        '''
                    }
                }
            }
        }


        stage('Terraform Approval') {
            steps {
                input(
                    message: '¿Quieres aplicar los cambios de Terraform?',
                    ok: 'Execute Apply'
                )
            }
        }


        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_PATH}") {

                    withCredentials([
                        azureServicePrincipal(
                            credentialsId: 'azure-service-principal',
                            subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                            clientIdVariable: 'ARM_CLIENT_ID',
                            clientSecretVariable: 'ARM_CLIENT_SECRET',
                            tenantIdVariable: 'ARM_TENANT_ID'
                        )
                    ]) {

                        sh '''
                            terraform apply tfplan
                        '''
                    }
                }
            }
        }
    }
}
