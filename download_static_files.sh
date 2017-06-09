dlHttpFiles() {
  mkdir -p /RackHD/on-http/static/http/common
  dir=/RackHD/on-http/static/http/common
  # pull down index from bintray repo and parse files from index
  pushd $dir
  wget --no-check-certificate https://dl.bintray.com/rackhd/binary/builds/ && \
      exec  cat index.html |grep -o href=.*\"|sed 's/href=//' | sed 's/"//g' > files
  for i in `cat ./files`; do
    wget --no-check-certificate https://dl.bintray.com/rackhd/binary/builds/${i}
  done
  # attempt to pull down user specified static files
  for i in ${HTTP_STATIC_FILES}; do
    wget --no-check-certificate ${i}
  done
  rm index.html
  popd
}

dlTftpFiles() {
  dir=/RackHD/on-tftp/static/tftp
  # pull down index from bintray repo and parse files from index
  pushd $dir
  wget --no-check-certificate https://dl.bintray.com/rackhd/binary/ipxe/ && \
      exec  cat index.html |grep -o href=.*\"|sed 's/href=//' | sed 's/"//g' > files
  for i in `cat ./files`; do
    wget --no-check-certificate https://dl.bintray.com/rackhd/binary/ipxe/${i}
  done
  # attempt to pull down user specified static files
  for i in ${TFTP_STATIC_FILES}; do
    wget --no-check-certificate https://bintray.com/artifact/download/rackhd/binary/ipxe/${i}
  done
  rm index.html
  popd
}

dlHttpFiles
dlTftpFiles
