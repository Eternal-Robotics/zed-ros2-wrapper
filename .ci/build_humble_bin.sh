#!/bin/bash

pwd_path="$(pwd)"
if [[ ${pwd_path:${#pwd_path}-3} == ".ci" ]] ; then cd .. && pwd_path="$(pwd)"; fi
ttk="===>"
root_path=${pwd_path}
repo_name=${PWD##*/}

echo "${ttk} Root repository folder: ${root_path}"
echo "${ttk} Repository name: ${repo_name}"

# Create the ROS 2 workspace
ws_path=${root_path}/ros2_ws/src
echo "${ttk} Create ROS2 workspace"
cd ..
mkdir -p ws_path 
cp -r ${repo_name} ${ws_path}
ls -lha ${ws_path}
ls -lha ${ws_path}/${repo_name}
cd ${root_path}

echo "${ttk} Building the ROS2 node in Humble installed from binaries."

echo "${ttk} Install ROS2 Humble"

echo "${ttk} Set Locale"
locale  # check for UTF-8
sudo apt-get update && sudo apt-get install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
locale  # verify settings

echo "${ttk} Setup Sources"
sudo apt-get install -y software-properties-common
sudo add-apt-repository universe
sudo apt-get update && sudo apt-get install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "${ttk} Install ROS 2 packages"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y ros-humble-ros-base ros-dev-tools

echo "${ttk} Sourcing the setup script"
source /opt/ros/humble/setup.bash

echo "${ttk} Initialize rosdep"
sudo rosdep init
rosdep update

echo "${ttk} Check environment variables"
env | grep ROS

echo "${ttk} ROS2 Humble is ready"

echo "${ttk} Install Node dependencies"
cd ${ws_path}
rosdep install --from-paths src --ignore-src -r -y

echo "${ttk} Build the node"
colcon build --symlink-install --cmake-args=-DCMAKE_BUILD_TYPE=Release --parallel-workers $(nproc)

cd ${root_path}











