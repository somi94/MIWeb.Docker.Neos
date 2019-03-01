# MIWeb.Docker.Neos
Docker image for Neos CMS sites and applications

## Usage
### Prequisites
[Docker](https://www.docker.com/)

[Docker Compose](https://docs.docker.com/compose/)
### Setupdocker
#### 1. Create a project directory
Create a empty directory at a location of your choice. This is the place where your project files will reside.

Example:
```
mkdir ~/Projects/Docker/MyNeosProject
```
#### 2. Create the docker compose file
Create a new file named `docker-compose.yml` inside your project folder.
Here is a example file, edit it to your needs:
```
version: '3.3'
services:
  web:
    image: miweb/neos:4.2
    ports:
    - '8050:80' # neos application will be available via port 8050, change it if you like
    links:
    - db:db
    volumes:
      # The app directory is where your neos development files will live. 
      # This includes project configuration, composer files and project specific packages (site package, site specific nodetypes...).
      - ./app:/usr/share/neos/project
      # The app-data/Neos directory will link to the neos installation.
      # This isn't necessary and can be omitted (especially in production environments) but is useful to keep an eye on neos core files and thirdparty packages.
      # On top of that it will allow your IDE to locate the neos classes.
      - ./app-data/Neos:/usr/share/neos/build
    environment:
#     SYSTEM_USER_NAME: 'johnnyd'                   # the development file owner
#     SYSTEM_USER_ID: 1001                          # the id of the development file owner (should match user id on host system)
      FLOW_CONTEXT: 'Development'                   # the application context
      NEOS_USER_NAME: 'john'                        # neos username    
      NEOS_USER_PASSWORD: 'john'                    # neos password
      NEOS_USER_FIRSTNAME: 'John'                   # your firstname
      NEOS_USER_LASTNAME: 'Doe'                     # your lastname
      NEOS_SITE_PACKAGE: 'Neos.Demo'                # the site package to use (will be imported automatically)
#     use this to start with a empty site:
#     NEOS_SITE_PACKAGE: 'My.New.Site'              # the site package to use (will be created and imported automatically)
#     NEOS_SITE_NAME: 'New Neos Site!'
      MYSQL_USER: root                              # mysql username (has to match user defined for db container)
      MYSQL_PASSWORD: root                          # mysql password (has to match password defined for db container)
      MYSQL_DATABASE: database                      # mysql database (has to match database defined for db container)
  db:
    image: mariadb
    command: ['--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci']
    restart: always
    volumes:
    - ./app-data/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: root
      MYSQL_PASSWORD: root
      MYSQL_DATABASE: database
```
#### 3. Run it
Navigate to your project directory and start docker compose.

Example:
```
cd ~/Projects/Docker/MyNeosProject
docker-compose up
```

Alternative to avoid image caching
```
cd ~/Projects/Docker/MyNeosProject
docker-compose build --no-cache --pull
docker-compose up
```

#### 4. Have a look at the results
Use your webbrowser to navigate to your neos installation: `http://localhost:{your_port}/`

Following my example compose file it would be: `http://localhost:8050/`

You should see the the neos demo page (or whatever page you defined as your site package inside your compose file).

Gratz, you've successfully installed neos!

### Starting development
After finishing setup, you can start development.
Those are the most important file locations:
#### app/composer.json
Contains the dependencies of your project. This will be linked to your neos build automatically.
#### app/Packages
Contains all project specific packages. Best practice would be to NOT version packages here at all, but to require them via composer.json. A exception could be the project specific site package.
But for development environments it can be useful to store mutiple packages here that you actively develop on. Example:
```
# Clone dev package
git clone https://github.com/myuser/My.Dev.Package app/Packages/My.Dev.Package
# Exclude dev package from versioning
echo "/app/Packages/My.Dev.Package" >>> ".gitignore"
# Remove previously installed package (if any)
docker exec my_neos_container rm -rf /usr/share/neos/project/Packages/*/My.Dev.Package/
# Trigger composer update
docker exec my_neos_container composer update
```
This is a example for adding dev packages manually. The provided neos-utils contain some tools to do it automatically. Read more about it in the section "Setup development environment"

**Important: if not already done, rememver to add the dev package to your composer.json, otherwise composer will never use it.**

**Important: if you add a dev package that was installed via composer before, make shure to delete it from the container. Otherwise composer will never use your local dev package.** 

#### app/Configuration
Your projects configuration. In a fresh installation, this directory contains a default Settings.yaml, modify it to your needs.

All context specific settings are stored in a subdirectory, named after the active context.

So in `Development` mode, your database credentials will be stored inside `app/Configuration/Development/Settings.yaml`.

**It is highly recommended that you store all necessary credentials inside the projects context configuration file. If you use version control (like git), you should ensure that the context configuration file (and the docker-compose file) will not get versioned to avoid credentials inside your vcs repository.**

**To do this via git, just add the following lines to your .gitignore file:**
```
/app/Configuration/*/*
/docker-compose.yml
```

### Creating a project image
It is recommended to create a custom image for your neos project.
To do that, just add a Dockerfile to your project:
```
FROM somi94/neos:latest

ADD app /usr/share/neos/project
RUN chown -R root:www-data /usr/share/neos/project

RUN neos-utils build update
```

Also you should add a .dockerignore to exclude docker volumes and other environment data from build context:
```
/app-data
/app/Packages/*/*
!/app/Packages/My.New.Site/*
```

Now you can use it for development environments using docker compose like this:
```
version: '3.3'
services:
  web:
    # Name of the project image
    image: my/project-dev
    # Name
    build: .
    ports:
    # The port the container listens to.
    - '8050:80'
    links:
    - db:db
    volumes:
      # Those volume definitions are optional
      - ./app:/usr/share/neos/project
      - ./app-data/Neos:/usr/share/neos/build
    environment:
      SYSTEM_USER_NAME: 'johnnyd'                   # the development file owner
      SYSTEM_USER_ID: 1002                          # the id of the development file owner (should match user id on host system)
      # Example for automatically adding development packages
      DEV_PACKAGE_LIST: >-
        MIWeb.Neos.NodeTypes:https://github.com/somi94/MIWeb.Neos.NodeTypes
        MIWeb.Neos.Privacy:https://github.com/somi94/MIWeb.Neos.Privacy
      # The applications context. Defaults are 'Development' and 'Production'
      FLOW_CONTEXT: 'Development'
      # The initial neos login. Feel free to define one yourself.
      NEOS_USER_NAME: 'my_neos_user'
      NEOS_USER_PASSWORD: 'my_neos_password'
      NEOS_USER_FIRSTNAME: 'John'
      NEOS_USER_LASTNAME: 'Doe'
      # The initial site package
      NEOS_SITE_PACKAGE: 'My.New.Site'              # the site package to use (will be created and imported automatically)
      NEOS_SITE_NAME: 'New Neos Site!'
      # Database connection info. Has to match the credentials defined for the "db" service below (Could also use a external database).
      MYSQL_HOST: 'db'
      MYSQL_USER: 'my_db_user'
      MYSQL_PASSWORD: 'my_db_password'
      MYSQL_DATABASE: 'database'
  db:
    # The database container name. Can be omitted in standalone environments
    image: mariadb
    command: ['--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci']
    restart: always
    volumes:
    - ./app-data/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 'my_db_root_password'
      MYSQL_USER: 'my_db_user'
      MYSQL_PASSWORD: 'my_db_password'
      MYSQL_DATABASE: 'database'
```
To use it, just run:
```
docker-compose build --no-cache --pull
docker-compose up
```

A example for simple production environments could be:
```
version: '3.3'
services:
  web:
    # Name of the project image
    image: my/project
    # Name
    build: https://github.com/myuser/My.Project
    ports:
    # The port the container listens to.
    - '8050:80'
    links:
    - db:db
    volumes:
      # Those volume definitions are optional
      - ./app:/usr/share/neos/project
    environment:
      # The applications context. Defaults are 'Development' and 'Production'
      FLOW_CONTEXT: 'Production'
      # The initial neos login. Feel free to define one yourself.
      NEOS_USER_NAME: 'my_neos_user'
      NEOS_USER_PASSWORD: 'my_neos_password'
      NEOS_USER_FIRSTNAME: 'John'
      NEOS_USER_LASTNAME: 'Doe'
      # The initial site package
      NEOS_SITE_PACKAGE: 'My.New.Site'              # the site package to use (will be created and imported automatically)
      # Database connection info. Has to match the credentials defined for the "db" service below (Could also use a external database).
      MYSQL_HOST: 'db'
      MYSQL_USER: 'my_db_user'
      MYSQL_PASSWORD: 'my_db_password'
      MYSQL_DATABASE: 'database'
  db:
    # The database container name. Can be omitted in standalone environments
    image: mariadb
    command: ['--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci']
    restart: always
    volumes:
    - ./app-data/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 'my_db_root_password'
      MYSQL_USER: 'my_db_user'
      MYSQL_PASSWORD: 'my_db_password'
      MYSQL_DATABASE: 'database'
```
Using this approach, you can build new versions of you application directly from your projects git repository (in this case: `https://github.com/myuser/My.Project`), without the need to clone it before.

This is only a quick and dirty "deployment" solution. Of course, a cleaner solution would be to build your image beforehand and push it to a docker repository for deployments to production environments, or use a automatic build service along with your docker repository (like docker hub). But nobody is perfect :)

### Setup development environment

#### 1. The image
Your first step should be to prepare your projects image. Have a look at "Creating a project image" to learn how to do that.

#### 2. The devlopment environment
Your second step should be to define your dev environment. You can do this via docker-compose. Have a look at "Creating a project image" to learn how to do that.

#### 3. Add your first local dev package
To add a new development package, follow those steps:

##### 1. Create the folder: app/Packages/My.New.Package
##### 2. Create a composer.json inside
```
{
  "name": "my/new-package",
  "type": "neos-plugin",
  "license": "GPL-3.0-or-later",
  "description": "Neos is awesome!",
  "require": {
      "neos/neos": "*"
  },
  "autoload": {
    "psr-4": {
      "My\\New\\Package\\": "Classes/"
    }
  },
  "extra": {
    "neos": {
      "package-key": "My.New.Package"
    }
  }
}
```
##### 3. Add it to projects composer.json (at: `app/composer.json`)
```
[...]
  "require": {
      [...]
      "my/new-package": "dev-master"
  }
[...]
```
##### 4. Run composer update
```
docker exec my_neos_container composer update
```
OR
```
docker exec -it my_neos_container bash
composer update
```
##### 5. Start development
Your package should now be linked to your project, and you are ready to develop.
Have a look at the official Neos documentation to learn about package development:
https://neos.readthedocs.io/en/stable/ExtendingNeos/index.html

## ToDos
List of future features that have not been implemented yet.
* Use nginx and more lightweight base image
* Prune existing site and import a new one as soon as site package changed
* Reimport site as soon as contents in package change
* Add documentation and autocomplete for neos utils
* Add default gitignore (to ignore context configuration)
