#!/usr/bin/env bash
set -e -u -o pipefail

RVM_VERSION=2.7.0
RAILS_ROOT=/home/ilya/hocomoco11_app
REMOTE_REPOSITORY=origin
BRANCH=master
export SECRET_KEY_BASE=verySecretKey
export RAILS_ENV=production


BUNDLE_WRAPPER="/usr/local/rvm/wrappers/ruby-${RVM_VERSION}/bundle"

COMMAND="$1"
COMMIT_SHA="$2"

stop() {
  ps aux | grep unicorn | grep master | grep $RAILS_ROOT | sed -re 's/\s+/\t/g' | cut -f2 | xargs --no-run-if-empty kill 
}

start() {
  $BUNDLE_WRAPPER exec unicorn -Dc $RAILS_ROOT/config/unicorn.rb
}

deploy(){
  pushd "$RAILS_ROOT"
  git fetch --all
  #if  [ "$( git rev-parse $BRANCH )" != "${COMMIT_SHA}" ]; then
  if  [ "$( git rev-parse $BRANCH )" != "$( git rev-parse ${REMOTE_REPOSITORY}/${BRANCH} )" ]; then
    #git checkout --force "${COMMIT_SHA}"
    git checkout --force "${REMOTE_REPOSITORY}/${BRANCH}"
    $BUNDLE_WRAPPER install
    $BUNDLE_WRAPPER exec rake assets:precompile
    stop
    start
  fi
  popd
}


case "$COMMAND" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    start
    stop
    ;;
  deploy)
    deploy
    ;;
esac
