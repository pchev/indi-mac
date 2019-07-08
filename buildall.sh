rm -rf testapp
source build_env
./build_indi.sh >build_indi.log 2>&1
./install_indi.sh > install_indi.log 2>&1
./install_libraries.sh >install_libraries.log 2>&1
./install_tar.sh >install_tar.log 2>&1

