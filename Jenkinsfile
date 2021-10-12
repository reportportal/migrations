#!groovy

node {

    load "$JENKINS_HOME/jobvars.env"

    stage('Checkout') {
        checkout scm
    }


    stage('Build') {
        docker.withServer("$DOCKER_HOST") {

            withEnv(["AWS_URI=${AWS_URI}", "AWS_REGION=${AWS_REGION}"]) {

                stage('Build Docker Image') {
                    sh 'docker build -t reportportal-dev/db-scripts -t ${AWS_URI}/migrations .'
                }

                stage('Run Migrations') {
                    sh "docker-compose -p reportportal -f $COMPOSE_FILE_RP run --rm migrations up"
                }

                stage('Push to registy') {
                    sh 'docker tag reportportal-dev/db-scripts ${AWS_URI}/migrations'
                    def image = env.AWS_URI + '/migrations'
                    def url = 'https://' + env.AWS_URI
                    def credentials = 'ecr:' + env.AWS_REGION + ':aws_credentials'
                    docker.withRegistry(url, credentials) {
                        docker.image(image).push('SNAPSHOT-${BUILD_NUMBER}')
                    }
                }

                stage('Cleanup') {
                    docker.withServer("$DOCKER_HOST") {
                        withEnv(["AWS_URI=${AWS_URI}"]) {
                            sh 'docker rmi ${AWS_URI}/migrations:SNAPSHOT-${BUILD_NUMBER}'
                            sh 'docker rmi ${AWS_URI}/migrations:latest'
                        }
                    }
                }
            }
        }
    }

}
