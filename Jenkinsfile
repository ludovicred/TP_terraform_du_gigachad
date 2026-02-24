pipeline {
    agent any

    parameters {
        choice(
            name: 'Client', 
            choices: ['Mazda', 'Marc', 'Mairie2Chateauroux'],
            description: 'Quel client ?'
        )
        choice(
            name: 'ENVIRONMENT', 
            choices: ['dev', 'val', 'prod'], 
            description: 'Sur quel environnement ?'
        )
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Que faire ?'
        )
        string(
            name: 'pour_le_fun',
            defaultValue: '',
            description: 'message ecrit dans le log'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Message : ${params.pour_le_fun}"
            }
        }

        stage('Terraform Init') {
            steps {
                sh "terraform init -reconfigure -backend-config='key=${params.Client}-${params.ENVIRONMENT}.tfstate'"
            }
        }

        stage('Terraform Validate') {
            when { expression { params.ACTION == 'apply' } }  // inutile pour un destroy
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh "terraform plan -var='nom_du_client=${params.Client}' -out=tfplan"
            }
        }

        stage('Approval') {
            steps {
                input message: "Confirmer ${params.ACTION} sur ${params.Client} - ${params.ENVIRONMENT} ?", ok: 'Confirmer'
            }
        }

        stage('Terraform Apply') {
            when { expression { params.ACTION == 'apply' } }
            steps {
                sh 'terraform apply tfplan'
            }
        }

        stage('Terraform Destroy') {
            when { expression { params.ACTION == 'destroy' } }
            steps {
                sh "terraform destroy -var='nom_du_client=${params.Client}' -auto-approve"
            }
        }
    }
}

/*pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Pas besoin de credentials ici, le rôle EC2 s'en occupe
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
*/