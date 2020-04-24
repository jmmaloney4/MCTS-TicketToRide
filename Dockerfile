FROM swift:5.2.2-bionic
VOLUME /output/
COPY . /opt/build/
WORKDIR /opt/build/
RUN swift build
ENTRYPOINT ["swift", "run", "TTR", "./east.json", "25", "-o", "/output/out.csv"]