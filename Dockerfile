FROM centos:latest

# Install dependency dasar
RUN yum update -y && yum install -y \
    openssh-server tmate curl gnupg2 

# Tambahkan repo SQL Server
RUN curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/8/mssql-server-2019.repo \
    && curl -o /etc/yum.repos.d/mssql-tools.repo https://packages.microsoft.com/config/rhel/8/prod.repo 

# Install SQL Server & Tools
RUN yum install -y mssql-server mssql-tools unixODBC-devel \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && source ~/.bashrc

# Konfigurasi SQL Server
RUN /opt/mssql/bin/mssql-conf set accept-eula Y \
    && /opt/mssql/bin/mssql-conf set memory.memorylimitmb 2048 \
    && systemctl enable mssql-server

# Setup SSH & tmate
RUN mkdir /run/sshd \
    && echo "sleep 5" >> /openssh.sh \
    && echo "tmate -F &" >> /openssh.sh \
    && echo "/usr/sbin/sshd -D &" >> /openssh.sh \
    && echo "/opt/mssql/bin/sqlservr" >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:147 | chpasswd \
    && chmod 755 /openssh.sh

# Expose port SQL Server & SSH
EXPOSE 1433 22 80 4469
CMD ["/openssh.sh"]
