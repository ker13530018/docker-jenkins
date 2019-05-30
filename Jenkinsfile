node {
    def tag = ''
    def success = true
    def errorMessage = ''
    try {
        stage('prepare network') {
            sh '[ $(docker network ls -f name=kubix_network -q) ] && echo \'network already exists\' ||  docker network create kubix_network'
        }

        stage('pull') {
            git credentialsId: 'user-test', url: 'https://test.com/test/mock-server.git'
        }
        
        stage('build image') {
            tag = sh(script: 'git describe --tags $(git rev-list --tags --max-count=1)', returnStdout: true).trim()
            echo "1. tag name : ${tag}"
            if (!tag) {
                tag = TAG
            }
            sh "docker build -t registry.test.com/test/mock-server:${tag} . "
        }
        
        stage('push image') {
            withDockerRegistry(credentialsId: 'user-test', url: 'https://registry.test.com/test/mock-server') {
                // some block
                echo "2. tag name : ${tag}"
                sh "docker push registry.test.com/test/mock-server:${tag}"
                sh "docker tag registry.test.com/test/mock-server:${tag} registry.test.com/test/mock-server:latest"
            }
        }
        stage('run image') {
            try {
                sh "docker-compose -f docker-compose-${ENV}.yaml down"
            } catch (e) {
                echo e.getMessage()
            }
            sh "docker-compose -f docker-compose-${ENV}.yaml run -d -e AUTH_URL=${AUTH_URL} -e AUTH_SECRET=${AUTH_SECRET} --name=mock-server mock-server"
        }
        
        stage('clear image') {
            def result = sh(returnStdout:true, script: '[ $(docker images -f dangling=true -aq) ] && echo \'next step\' || echo \'not found\' ' ).trim()
            // 
            if (result == "next step") {
                sh 'docker rmi $(docker images -f dangling=true -aq)'
            }
        } 
        
    } catch (e) { 

        success = false
        errorMessage = e.getMessage()
        throw e

    } finally {
        // Success or failure, always send notifications
        notifyBuild(success, errorMessage)
    }
    
}

def notifyBuild(boolean success, String err) {
  // Default values
  def colorCode = '#FF0000'
  def subject = "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' </p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (success) {
    colorCode = '#00FF00'
    summary = "${summary} Succeeded."
  } else {
    colorCode = '#FF0000'
    summary = "${summary} Error : ${err}"
  }

  // Send notifications
  slackSend baseUrl: '', channel: '', color: colorCode, message: summary, token: ''

}

