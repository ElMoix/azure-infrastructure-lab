pipeline {

    agent any

    options {
        ansiColor('xterm')
        timestamps()
    }

    environment {
        TERRAFORM_ENV = "dev"
        TERRAFORM_PATH = "terraform/environments/${TERRAFORM_ENV}"
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


        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_PATH}") {

                    withCredentials([
                        azureServicePrincipal('azure-service-principal')
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
                    ok: 'Ejecutar terraform apply'
                )
            }
        }


        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_PATH}") {

                    withCredentials([
                        azureServicePrincipal('azure-service-principal')
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
