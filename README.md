# home_listings
Docker Containerization for Web Application Implementation  

- name: Setup web server and deploy content
  hosts: aws_amazon_linux
  vars:
    git_repo_url: 'https://github.com/Oreire/home_listing.git'
    docker_image: 'nginx:latest'
    container_name: 'portal'
    repo_directory: '/home/ec2-user/home_listings'

  tasks:
    - name: Install Git
      yum:
        name: git
        state: present
      become: yes

    - name: Clone Git repository
      git:
        repo: "{{ git_repo_url }}"
        dest: "{{ repo_directory }}"

    - name: Change directory to Git repository
      command: pwd
      args:
        chdir: "{{ repo_directory }}"

    - name: Install Docker
      yum:
        name: docker
        state: present
      become: yes

    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes
      become: yes

    - name: Add ec2-user to docker group
      user:
        name: ec2-user
        groups: docker
        append: yes
      become: yes

    - name: Restart Docker service
      systemd:
        name: docker
        state: restarted
      become: yes

    - name: Pull Nginx image from Docker Hub
      docker_image:
        name: nginx
        source: pull

    - name: Create NGINX container
      docker_container:
        name: "{{ container_name }}"
        image: "{{ docker_image }}"
        state: started
        ports:
          - "80:80"
        restart_policy: always
        
    - name: Copy index.html to host
      copy:
        src: "{{ repo_directory }}/index.html"
        dest: "/usr/share/nginx/html/index.html"
        mode: '0644'
      become: yes

    - name: Copy styles.css to host
      copy:
        src: "{{ repo_directory }}/styles.css"
        dest: "/usr/share/nginx/html/styles.css"
        mode: '0644'
      become: yes

    - name: Copy image folder to host
      copy:
        src: "{{ repo_directory }}/image"
        dest: "/usr/share/nginx/html/image"
        mode: '0755'
      become: yes
