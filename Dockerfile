FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata


RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3-dev \
    python3-pip \
    apt-utils
    
RUN apt-get update && apt-get install -y \ 
    wget \
    lsb-release \
    software-properties-common

# RUN wget -c https://raw.githubusercontent.com/qboticslabs/ros_install_noetic/master/ros_install_noetic.sh && \
#     chmod +x ./ros_install_noetic.sh && \
#     ./ros_install_noetic.sh

COPY ros_install_noetic_nosudo.sh ./ros_install_noetic_nosudo.sh
RUN chmod +x ./ros_install_noetic_nosudo.sh && \
    ./ros_install_noetic_nosudo.sh

RUN mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws/src && \
    /bin/bash -c "source /opt/ros/noetic/setup.bash; catkin_init_workspace" && \
    cd ~/catkin_ws/ && \
    /bin/bash -c "source /opt/ros/noetic/setup.bash; catkin_make"

RUN echo "source //opt/ros/noetic/setup.bash" >> ~/.bashrc && \
    echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc 

#installazione dipendenze ROS noetic
RUN apt-get update && apt-get install -y \
    ros-noetic-ackermann-steering-controller \
    ros-noetic-costmap-2d \
    ros-noetic-nav-core \
    ros-noetic-base-local-planner

#installazione pacchetti zed
RUN mkdir -p ~/catkin_ws/src && \
    cd ~/catkin_ws/src && \
    git clone https://github.com/ZancleEDrive/steer_bot && \
    git clone https://github.com/ZancleEDrive/steer_drive_ros.git && \
    cd steer_drive_ros && \
    git checkout melodic-devel && \
    apt install python3-rosdep && \
    cd ~/catkin_ws && \
    rosdep init && \
    rosdep update && \
    rosdep check --from-paths src --ignore-src --rosdistro noetic && \
    rosdep install --from-paths src --ignore-src --rosdistro noetic -y && \
    apt install -y ros-noetic-hector-slam && \
    cd ~/catkin_ws/src 

# RUN cd ~/catkin_ws/src && \
#     git clone https://github.com/ZancleEDrive/autonomous_steer_bot.git && \
#     git clone https://github.com/ZancleEDrive/robot_localization.git && \
#     cd robot_localization && \
#     git checkout noetic-devel && \
#     apt install ros-noetic-hector-localization && \
#     apt install ros-noetic-robot-localization

# ENTRYPOINT cd ~/catkin_ws && \
#     catkin_make && \
#     echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

CMD ["/bin/bash"]
