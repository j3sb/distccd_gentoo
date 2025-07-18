FROM gentoo/stage3:latest

RUN emerge --sync --quiet

RUN echo sys-devel/gcc cxx > /etc/portage/package.use/gcc

# make sure gcc is installed, it should be by default
RUN emerge sys-devel/gcc --quiet
# install clang
RUN emerge llvm-core/clang
# install distcc
RUN emerge sys-devel/distcc --quiet
# cross dev for arm64 machines (eg. raspberry pi)
RUN emerge sys-devel/crossdev
RUN emerge app-eselect/eselect-repository
RUN eselect repository create crossdev
RUN crossdev --stable -t aarch64-unknown-linux-gnu

# make image smaller
RUN emerge --depclean --quiet

# create log file and set permissions
RUN touch /var/log/distccd.log
RUN chown distcc:root /var/log/distccd.log

# clean cache for smaller image size
RUN rm -rf /var/tmp/portage /var/cache/distfiles /var/cache/binpkgs /var/db/repos/gentoo

# set run options
ENV OPTIONS --port 3632 --log-file /var/log/distccd.log --allow 192.168.0.0/16 --allow 10.8.0.0/16

# distccd port
EXPOSE 3632

USER distcc

ENTRYPOINT /usr/bin/distccd --daemon $OPTIONS && echo daemon is starting! && tail -f /var/log/distccd.log
