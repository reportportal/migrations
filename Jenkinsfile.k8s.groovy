#!groovy

//String podTemplateConcat = "${serviceName}-${buildNumber}-${uuid}"
def label = "worker-${env.JOB_NAME}-${UUID.randomUUID().toString()}"
println("Worker name: ${label}")

podTemplate(
        label: "${label}",
        containers: [
                containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave:alpine'),
                containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:v3.0.2', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'gcloud', image: 'gcr.io/cloud-builders/gcloud', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
                containerTemplate(
                        name: 'buildkit',
                        image: 'moby/buildkit:master',
                        command: 'cat',
                        privileged: true,
                        ttyEnabled: true)
        ],
        volumes: [
                secretVolume(mountPath: '/etc/.docker', secretName: 'dockerconfigjson-secret'),
                secretVolume(mountPath: '/etc/gcr-acc', secretName: 'kaniko-secret'),
        ]
) {

    node("${label}") {
        /**
         * General ReportPortal Kubernetes Configuration and Helm Chart
         */
        def k8sDir = "kubernetes"
        def k8sChartDir = "$k8sDir/reportportal/v5"

        /**
         * Jenkins utilities and environment Specific k8s configuration
         */
        def ciDir = "reportportal-ci"
        def appDir = "app"
        def testsDir = "tests"

        parallel 'Checkout Infra': {
            stage('Checkout Infra') {
                sh 'mkdir -p ~/.ssh'
                sh 'ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts'
                sh 'ssh-keyscan -t rsa git.epam.com >> ~/.ssh/known_hosts'
//                dir('kubernetes') {
//                    git branch: "master", url: 'https://github.com/reportportal/kubernetes.git'
//
//                }
                dir(ciDir) {
                    git credentialsId: 'epm-gitlab-key', branch: "master", url: 'git@git.epam.com:epmc-tst/reportportal-ci.git'
                }
            }
        }, 'Checkout Migration Scripts': {
            stage('Checkout Migration Scripts') {
                dir('migrations') {
                    checkout scm
                }
            }
        }
        def utils = load "${ciDir}/jenkins/scripts/util.groovy"

        stage('Build Image') {
            def dCreds
            container ('docker') {
                sh "cat /etc/gcr-acc/or2-msq-epmc-tst-t1iylu-c9e5b963b6be.json | docker login -u _json_key --password-stdin gcr.io"
                dCreds = utils.execStdout('cat /root/.docker/config.json')
            }
            dir('migrations') {
                def baseDir = utils.execStdout('pwd')
                def configDir = '/tmp/.docker'
                container('buildkit') {
                    sh "mkdir $configDir"
                    writeFile file: "$configDir/config.json", text: dCreds
                    sh """
                        export DOCKER_CONFIG=$configDir/
                        buildctl-daemonless.sh build --frontend dockerfile.v0 --local context=$baseDir --local dockerfile=$baseDir --output type=image,name=gcr.io/or2-msq-epmc-tst-t1iylu/migrations,push=true
                    """
                }
            }
        }
    }
}

