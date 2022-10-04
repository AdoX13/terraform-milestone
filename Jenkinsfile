pipeline {
    agent any
    tools {
        terraform "terraform-test"
    }
    stages {
        stage('Git Prep'){
            steps {    
                sh 'rm -rf terraform-milestone'
                sh(returnStdout: true, script:
                '''
                    #!/bin/sh
                    if [ $(ls | grep terraform-milestone -c) = '1' ];then
                        cd terraform-milestone
                        git fetch --all
                        cd ..
                    else
                        git clone 'https://github.com/AdoX13/terraform-milestone.git'
                    fi
                '''.stripIndent())
            }
        }
    
        stage('Deploy'){
            steps{
                sh '''
                    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                    cd terraform-milestone
                    /var/jenkins_home/workspace/terraform-milestone/terraform-milestone/deploy.sh $ENVIRONMENT $DEPLOYMENT
                '''
            }
        }
    }
}

