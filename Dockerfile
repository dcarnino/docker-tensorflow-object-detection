FROM tensorflow/tensorflow:1.6.0-devel-gpu-py3

RUN apt-get update && yes | apt-get upgrade
RUN echo -e "\nalias python=python3" >> ~/.profile
RUN cat ~/.profile
RUN . ~/.profile
RUN apt-get install -y python-tk protobuf-compiler python-lxml git\
    && pip install Cython

RUN mkdir -p /tensorflow/models
RUN git clone https://github.com/tensorflow/models.git /tensorflow/models

WORKDIR /tensorflow/models/research
RUN sed -i '87d' object_detection/protos/ssd.proto \
    && sed -i -e "168s/range(num_boundaries)/list(range(num_boundaries))/" object_detection/utils/learning_schedules.py
RUN protoc object_detection/protos/*.proto --python_out=.

RUN pip install --upgrade pip \
    && pip install --upgrade dask \
    && pip install pandas \
    && pip install Pillow

RUN python setup.py sdist \
    && (cd slim && python setup.py sdist)

ENV PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim
