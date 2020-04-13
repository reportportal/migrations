#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }

    stage('Build') {
        docker.withServer("$DOCKER_HOST") {
            stage('Build Docker Image') {
                sh 'docker build -t reportportal-dev/migrations .'
            }

            stage('Run Migrations') {
                docker.withServer("$DOCKER_HOST") {
                    sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
                }
            }
            stage('Push to ECR') {
                docker.withServer("$DOCKER_HOST") {
                    sh 'docker tag reportportal-dev/migrations 334301710522.dkr.ecr.eu-central-1.amazonaws.com/db-scripts:SNAPSHOT-${BUILD_NUMBER}'
                    withAWS(credentials: 'IDofAwsCredentials', region: 'eu-central-1') {
                        ecrLogin()
                        sh 'docker push 334301710522.dkr.ecr.eu-central-1.amazonaws.com/db-scripts:SNAPSHOT-${BUILD_NUMBER}'
                    }
                }
            }
        }
    }

}
