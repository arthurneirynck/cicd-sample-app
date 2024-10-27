pipeline {
    agent any 

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/arthurneirynck/cicd-sample-app', branch: 'main'
            }
        }
        stage('Build') {
            steps {
                script {
                    // Clean up any existing container
                    sh '''
                        if [ $(docker ps -a -q -f name=samplerunning) ]; then
                            docker rm -f samplerunning
                        fi
                    '''

                    // Run the build script
                    sh './sample-app.sh'
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    // Define the IP address of the running app
                    APP_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' samplerunning)
                    
                    // Check the response
                    response=$(curl -s http://$APP_IP:5050/)
                    echo "$response"
                    
                    // Check if the response contains the expected IP
                    if ! echo "$response" | grep -q "You are calling me from"; then
                        echo "Test failed. Response:"
                        echo "$response"
                        currentBuild.result = 'FAILURE'
                    } else {
                        echo "Test passed."
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up the running container after build
                if [ $(docker ps -a -q -f name=samplerunning) ]; then
                    docker rm -f samplerunning
                fi
            }
        }
    }
}
