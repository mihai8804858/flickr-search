pipeline {
    agent any

    options {
        ansiColor('xterm')
        skipDefaultCheckout true
    }

    parameters {
        string(name: "BRANCH", defaultValue: "master")
        string(name: "VERSION", defaultValue: "1.0.0")
        choice(name: "CONFIGURATION", choices: ["Debug", "Release"])
        booleanParam(name: "RUN_TESTS", defaultValue: true)
        booleanParam(name: "DELIVER", defaultValue: false)
    }

    stages {
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }

        stage('SCM') {
            parallel {
                stage('Checkout PR') {
                    when { 
                    	expression { 
                    		env.CHANGE_BRANCH != null 
                    	} 
                    }

                    steps {
                        checkout([
                            $class: "GitSCM",
                            branches: [[name: "*/${env.CHANGE_BRANCH}"]],
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions: scm.extensions,
                            userRemoteConfigs: scm.userRemoteConfigs
                        ])
                    }
                }

                stage('Checkout Branch') {
                    when { 
                    	expression { 
                    		env.CHANGE_BRANCH == null && params.BRANCH != null
                    	} 
                    }

                    steps {
                        checkout([
                            $class: "GitSCM",
                            branches: [[name: "*/${params.BRANCH}"]],
                            doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                            extensions: scm.extensions,
                            userRemoteConfigs: scm.userRemoteConfigs
                        ])
                    }
                }
            }
        }

        stage('Dependencies') {
            steps {
                sh "bundle install"
            }
        }

        stage('Bump version') {
            when {
                expression {
                    env.CHANGE_BRANCH == null
                }
            }

            steps {
                sh "bundle exec fastlane bump_version version:${params.VERSION}"
            }
        }

        stage('Build') {
            when {
                expression {
                    env.CHANGE_BRANCH == null
                }
            }

            steps {
                sh "bundle exec fastlane build configuration:${params.CONFIGURATION}"
            }
        }

        stage('Test') {
            when {
                expression {
                    env.CHANGE_BRANCH != null || params.RUN_TESTS
                }
            }

            steps {
                sh "bundle exec fastlane test"
            }
        }

        stage('Deliver') {
            when {
                expression {
                    env.CHANGE_BRANCH == null && params.DELIVER
                }
            }

            steps {
                sh "bundle exec fastlane release_build_to_testflight configuration:${params.CONFIGURATION}"
            }
        }

        stage('Commit') {
            when {
                expression {
                    env.CHANGE_BRANCH == null && params.DELIVER
                }
            }

            steps {
                sh "bundle exec fastlane commit_version version:${params.VERSION}"
            }
        }

        stage('Tag') {
            when {
                expression {
                    env.CHANGE_BRANCH == null && params.DELIVER
                }
            }

            steps {
                sh "bundle exec fastlane tag_version version:${params.VERSION}"
            }
        }
    }
}
