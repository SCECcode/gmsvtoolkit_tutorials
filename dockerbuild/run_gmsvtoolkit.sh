# -rm removes container on exit
# -it indicates inteactive + --tty so that users are at an interactive tty command line when the container starts
docker run -p 8888:8888 --rm -i -t --mount type=bind,source="$(pwd)"/target,destination=/home/scecuser/target gmsvtoolkit_jupyter:latest
