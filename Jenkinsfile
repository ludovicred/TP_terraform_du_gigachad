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
        string(
            name: 'pour_le_fun',
            defaultValue: '',  // ✅ Ajout du defaultValue manquant
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
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var='nom_du_client=${params.Client}' -out=tfplan"
            }
        }
        stage('Terraform Apply') {
    steps {
        sh "terraform apply -var='nom_du_client=${params.Client}' tfplan"
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