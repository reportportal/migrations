#!groovy

//String podTemplateConcat = "${serviceName}-${buildNumber}-${uuid}"
def label = "worker-${env.JOB_NAME}-${UUID.randomUUID().toString()}"
println("Worker name: ${label}")

podTemplate(
        label: "${label}",
        containers: [
                containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave:alpine'),
                containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:v3.0.2', command: 'cat', ttyEnabled: true),
                containerTemplate(name: 'buildkit', image: 'moby/buildkit:master-rootless', command: 'buildctl-daemonless.sh', ttyEnabled: true)
        ],
        volumes: [
                hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
                secretVolume(mountPath: '/etc/.dockercreds', secretName: 'docker-creds'),
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
                dir('kubernetes') {
                    git branch: "master", url: 'https://github.com/reportportal/kubernetes.git'

                }
                dir(ciDir) {
                    git credentialsId: 'epm-gitlab-key', branch: "master", url: 'git@git.epam.com:epmc-tst/reportportal-ci.git'
                }
            }
        }, 'Checkout Service': {
            stage('Checkout Service') {
                dir('app') {
                    checkout scm
                }
            }
        }
        def utils = load "${ciDir}/jenkins/scripts/util.groovy"
        def helm = load "${ciDir}/jenkins/scripts/helm.groovy"
        def docker = load "${ciDir}/jenkins/scripts/docker.groovy"

        docker.init()
        helm.init()


        utils.scheduleRepoPoll()

        def majorVersion;
        dir('app') {
            majorVersion = utils.execStdout('cat VERSION')
        }

        def srvRepo = "quay.io/reportportal/service-index"
        def srvVersion = "$majorVersion-BUILD-${env.BUILD_NUMBER}"
        def tag = "$srvRepo:$srvVersion"


        stage('Build Image') {
            container('buildkit') {
                sh 'buildctl --addr kube-pod://buildkit build --frontend dockerfile.v0 --local context=./ --local dockerfile=./'
            }
            sh "docker build -t $tag -f DockerfileDev ."
        }
    }
}

