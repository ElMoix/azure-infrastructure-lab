pipeline {

    agent any

    options {
        ansiColor('xterm')
    }

    environment {
        TERRAFORM_ENV = "dev"
    }


    stages {

        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/ElMoix/azure-infrastructure-lab.git',
                    credentialsId: 'github-token'
                )
            }
        }


        stage('Terraform Init') {
            steps {
                dir('terraform/environments/dev') {
                    sh 'terraform init'
                }
            }
        }


        stage('Terraform Validate') {
            steps {
                dir('terraform/environments/dev') {
                    sh 'terraform validate'
                }
            }
        }


        stage('Terraform Plan') {
            steps {
                dir('terraform/environments/dev') {
                    sh 'terraform plan'
                }
            }
        }

    }
}
