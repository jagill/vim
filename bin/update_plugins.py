#!/usr/bin/env python

import os
import sys
import subprocess
import logging
import optparse
import urllib
import shutil
import tempfile
from zipfile import ZipFile
from tarfile import TarFile

try:
    import yaml
except ImportError:
    print "Failed to import yaml.  Please install it with 'pip install PyYAML' or equivalent."
    sys.exit(2)

#Type of info needed/wanted:
#name -- id and directory
#vimscript url
#resource url
#repo (what type) or direct download
#vim files, zip, tar.gz, vimball

def wget(url, target_file):
    logging.debug("Fetching %s from url %s" % (target_file, url))
    data = urllib.urlopen(url)
    with open(target_file, 'w') as file:
        file.write(data.read())


def refresh_pathogen(vim_dir, options):
    logging.info("Refreshing pathogen")
    pathogen_dir_path = os.path.join(vim_dir, 'autoload')
    pathogen_file_path = os.path.join(pathogen_dir_path, 'pathogen.vim')
    if options.clean:
        logging.debug("Cleaning pathogen dir %s" % pathogen_dir_path)
        shutil.rmtree(pathogen_dir_path)
    if not os.path.isdir(pathogen_dir_path):
        os.mkdir(pathogen_dir_path)
    remote_pathogen_repo = 'http://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim'
    wget(remote_pathogen_repo, pathogen_file_path)
    logging.info("Refreshed pathogen from github.")


def is_plugin_list_ok(plugins):
    # Check plugin
    if not plugins:
        logging.info("Plugin file is empty.")
        return True
    logging.debug("Found %d plugins" % len(plugins))
    #Check for duplicate names -- leads to annoying bugs.
    names_list = [plugin.get('name') for plugin in plugins if plugin.get('name')]
    if len(names_list) != len(set(names_list)):
        print "Duplicate names found."
        return False
    if len(names_list) != len(plugins):
        print "Some plugins don't have names."
        return False
    #if [1 for plugin in plugins if 'file_type' not in plugin]:
        #print "Some plugins do not have file_type"
        #return False
    return True

def install_plugin(plugin, plugin_dir, options={}):
    if not os.path.exists(plugin_dir):
        os.mkdir(plugin_dir)
    if 'extra_dir' in plugin:
        target_dir = os.path.join(plugin_dir, plugin['extra_dir'])
    else:
        target_dir = plugin_dir
    if options.debug:
        quiet_stdout = None
        quiet_opt='-v'
    elif options.verbose:
        quiet_stdout = None
        quiet_opt=None
    else:
        #suppress output
        quiet_stdout = subprocess.PIPE
        quiet_opt='-q'
    #if it's a git repo, git clone it.
    if plugin.get('repo'):
        if plugin['repo_type'] == 'git':
            logging.debug("Checking for existing git repo for %s" % plugin['name'])
            missing_repo = subprocess.call(['ls', os.path.join(target_dir, '.git')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if missing_repo:
                logging.info("Fetching %s from git repo %s" % (plugin['name'], plugin['repo']))
                args = ['git', 'clone', '--no-progress', '--depth', '0', plugin['repo'], target_dir]
                if quiet_opt:
                    args.insert(2,quiet_opt)
                subprocess.call(args, stdout=quiet_stdout)
            else:
                logging.info("Pulling %s from git repo %s" % (plugin['name'], plugin['repo']))
                args = ['git', 'pull', '--no-progress']
                if quiet_opt:
                    args.insert(2,quiet_opt)
                subprocess.call(args, cwd=target_dir, stdout=quiet_stdout)
            if options.kill_repo:
                logging.debug("Killing cloned git repo for %s" % plugin['name'])
                shutil.rmtree(os.path.join(target_dir, '.git'))
            if plugin['name'] == 'pyflakes':
                #Special hack! pyflakes-vim needs a special fork of pyflakes in its dir.
                hack_dir = os.path.join(target_dir, plugin['hack_dir'])
                missing_repo = subprocess.call(['ls', os.path.join(hack_dir, '.git')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                if missing_repo:
                    args = ['git', 'clone', '--no-progress', '--depth', '1', plugin['hack_repo'], hack_dir]
                    if quiet_opt:
                        args.insert(2,quiet_opt)
                    subprocess.call(args, stdout=quiet_stdout)
                else:
                    args = ['git', 'pull', '--no-progress']
                    if quiet_opt:
                        args.insert(2,quiet_opt)
                    subprocess.call(args, cwd=hack_dir, stdout=quiet_stdout)


        elif plugin['repo_type'] == 'hg':
            logging.debug("Checking for existing hg repo for %s" % plugin['name'])
            missing_repo = not subprocess.call(['ls', os.path.join(target_dir, '.hg')], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if missing_repo:
                logging.info("Fetching %s from hg repo %s" % (plugin['name'], plugin['repo']))
                subprocess.call(['hg', 'clone', plugin['repo'], target_dir], stdout=quiet_stdout)
            else:
                subprocess.call(['hg', 'pull'], cwd=target_dir, stdout=quiet_stdout)
                subprocess.call(['hg', 'merge'], cwd=target_dir, stdout=quiet_stdout)
            if options.kill_repo:
                logging.debug("Killing cloned hg repo for %s" % plugin['name'])
                shutil.rmtree(os.path.join(target_dir, '.hg'))

        else:
            logging.error("Error: Did not understand repo_type %s found for plugin %s" % (plugin.get('repo_type'), plugin['name']))
    elif 'vim_org_id' in plugin:
        logging.info("Downloading vim script %s" % plugin['name'])
        url = "http://www.vim.org/scripts/download_script.php?src_id=%d" % plugin['vim_org_id']
        if plugin['file_type'] == 'vim':
            f_path = os.path.join(plugin_dir, plugin['plugin_type'], plugin['name']+'.vim')
            if not os.path.exists(os.path.dirname(f_path)):
                os.mkdir(os.path.dirname(f_path))
            wget(url, f_path)
        elif plugin['file_type'] == 'zip':
            with tempfile.TemporaryFile() as temp_f:
                temp_f.write(urllib.urlopen(url).read())
                with ZipFile(temp_f, 'r') as zip_f:
                    zip_f.extractall(target_dir)
        elif plugin['file_type'] == 'tar.gz' or plugin['file_type'] == 'tgz':
            with tempfile.TemporaryFile() as temp_f:
                temp_f.write(urllib.urlopen(url).read())
                with TarFile(temp_f, 'r') as zip_f:
                    zip_f.extractall(target_dir)

        else:
            logging.warn('Found plugin %s with unknown filetype %s' % (plugin['name'], plugin['file_type']))
    else:
        logging.warn('Found plugin %s without either vim_org_id or repo key.' % plugin['name'])




def main(options, args):
    options.verbose = options.verbose or options.debug
    options.clean = options.clean or options.full_clean
    if options.debug:
        logging.basicConfig(level=logging.DEBUG)
    elif options.verbose:
        logging.basicConfig(level=logging.INFO)

    logging.debug("Running script with args %s" % args)
    logging.debug("Script file is %s, which has abspath %s" % (__file__, os.path.abspath(__file__)))

    vim_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    logging.debug("Using vim dir %s" % vim_dir)

    bundle_dir = os.path.join(vim_dir, 'bundle')

    options.plugins_file = options.plugins_file or os.path.join(vim_dir, 'config', 'plugins.yml')
    logging.debug("Using plugins file %s" % options.plugins_file)

    if options.delete:
        for plugin_name in args:
            if plugin_name == 'pathogen':
                pathogen_dir = os.path.join(vim_dir, 'autoload')
                shutil.rmtree(pathogen_dir)
            else:
                plugin_dir = os.path.join(bundle_dir, plugin_name)
                shutil.rmtree(plugin_dir)
            logging.info("Deleted %s" % plugin_name)
        return 0

    if ('pathogen' in args) or options.pathogen:
        refresh_pathogen(vim_dir, options)

    plugins = []
    with open(options.plugins_file, 'r') as plugins_file:
        plugins = yaml.load(plugins_file)
            
    if not is_plugin_list_ok(plugins):
        logging.info("Plugin file did not validate.")
        return 1

    if args:
        plugins = [plugin for plugin in plugins if plugin['name'] in args]
        logging.debug("Will update plugins %s" % [plugin['name'] for plugin in plugins])

    if options.full_clean:
        #Setup a clean bundle dir
        try:
            logging.info("Deleting bundle directory %s" % bundle_dir)
            shutil.rmtree(bundle_dir)
        except OSError:
            #No directory; that's just fine.
            pass

    if not os.path.exists(bundle_dir):
        os.mkdir(bundle_dir)

    for plugin in plugins:
        try:
            plugin_dir = os.path.join(bundle_dir, plugin['name'])
            if options.clean:
                try:
                    logging.debug("Cleaning plugin dir %s" % plugin_dir)
                    shutil.rmtree(plugin_dir)
                except OSError:
                    logging.debug("No plugin dir %s to clean" % plugin_dir)
                    #nothing there!
                    pass
            install_plugin(plugin, plugin_dir, options)
        except:
            logging.error("Found error in plugin %s" % (plugin['name']))
            raise

    return 0

if __name__=='__main__':
    parser = optparse.OptionParser(usage='''%prog [options] PLUGINS_TO_UPGRADE''')
    parser.add_option('-f', '--file', dest='plugins_file', help='Plugin config file (in yaml).  Default=$VIMDIR/config/plugins.yml', default=None)
    parser.add_option('-v', '--verbose', dest='verbose', action='store_true', default=False, help='Print more output.  Default=%default')
    parser.add_option('-d', '--debug', dest='debug', action='store_true', default=False, help='Print even more output.  Can be quite noisy.  Default=%default')
    parser.add_option('-P', '--pathogen', dest='pathogen', action='store_true', default=False, help='Refresh pathogen.  Overriden by the use of pathogen in arguments.  Default=%default')
    parser.add_option('-c', '--clean', dest='clean', action='store_true', default=False, help='Delete existing directories before upgrading it.')
    parser.add_option('-C', '--full-clean', dest='full_clean', action='store_true', default=False, help='Delete ALL existing directories before upgrading.')
    parser.add_option('-D', '--delete', dest='delete', action='store_true', default=False, help='Delete listed plugins instead of upgrading them.')
    parser.add_option('-k', '--kill-repo', dest='kill_repo', action='store_true', default=False, help='Delete cloned repositories after cloning/updating.  May require a clean before next update.')

    (options, args) = parser.parse_args()

    sys.exit(main(options, args))




