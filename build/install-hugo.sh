
HUGO_VERSION=0.74.3
DL_SUFFIX=Linux-64bit

set -x
set -e

if [ ! -x local/bin/hugo ]
then
  mkdir -p local/bin local/tmp
  wget -P local/tmp/ https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_${DL_SUFFIX}.tar.gz
  tar -xvf local/tmp/hugo_${HUGO_VERSION}_${DL_SUFFIX}.tar.gz -C local/tmp
  mv local/tmp/hugo local/bin/hugo
  chmod +x local/bin/hugo
fi