if [ `uname` = "Darwin" ]; then
  ipconfig getifaddr en0
else
  echo 'ip: unknow'
fi
