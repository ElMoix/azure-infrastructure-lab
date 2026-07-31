pipeline {

    agent any

    options {
        ansiColor('xterm')
        timestamps()
    }

    parameters {
	choice(
    	name: 'ACTION',
    	choices: [
        	'deploy',
        	'destroy'
    	],
    	description: 'Terraform action'
	)
        
	choice(
            name: 'TERRAFORM_ENV',
            choices: [
                'dev',
                'prod'
            ],
            description: 'Terraform environment to deploy'
        )

        booleanParam(
            name: 'DEPLOY_VM',
            defaultValue: false,
            description: 'Deploy Azure Virtual Machine'
        )

        booleanParam(
            name: 'DEPLOY_SQL',
            defaultValue: false,
            description: 'Deploy Azure SQL Database'
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


        stage('Terraform Variables') {
            steps {
                dir("${TERRAFORM_PATH}") {
                    sh """
                        printf 'deploy_vm = %s\\ndeploy_sql = %s\\n' \
                        ${params.DEPLOY_VM} \
                        ${params.DEPLOY_SQL} \
                        > jenkins.auto.tfvars

                        cat jenkins.auto.tfvars
			terraform fmt jenkins.auto.tfvars
		    """
                }
            }
        }

        stage('QA') {
            steps {
                dir("${TERRAFORM_PATH}") {
                    sh '''
			echo "========== Terraform Format =========="
                	terraform fmt -check -recursive

			echo
                        echo "========== Terraform Validate =========="
                        terraform validate

                        echo
                        echo "========== TFLint =========="
                        tflint --init
                        tflint

                        echo
                        echo "========== Checkov =========="
                        checkov -d . --framework terraform --soft-fail
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
			script {
                            if (params.ACTION == "deploy") {
                                sh '''
				  terraform plan -out=tfplan
				'''
                            } else {
                                sh '''
				  terraform plan -destroy -out=tfplan
				'''
                            }
                        }
                    }
                }
            }
        }


        stage('Terraform Approval') {
            steps {
                input(
                    message: "Approve Terraform ${params.ACTION}?",
                    ok: 'Continue'
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
