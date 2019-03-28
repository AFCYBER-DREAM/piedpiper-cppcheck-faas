import os
import sh
from io import StringIO
from .util import build_temp_zipfiles, build_directories, unzip_files
import yaml 
from pathlib import Path


def handle(request):
    """handle a request to the function
    Args:
        req (str): request body
    """
    
    zip_files = build_temp_zipfiles(request)
    temp_directories = build_directories(request)
    cppcheck_reports = []

    for zip_file, temp_directory in zip(zip_files, temp_directories):
        unzip_files(zip_file, temp_directory.name)
        os.chdir(temp_directory.name)

        options = Path("options.yml")
        if(options.is_file() == False or options.exists() == False):
           #options.yml not found, resorting to defaults
            report = run_cppcheck('.')
        else:
            with open('options.yaml') as f:
                dataMap = yaml.load(f)
                report = run_cppcheck_w_opt('.', dataMap['options'])
        cppcheck_reports.append(report)

    return '\n'.join(cppcheck_reports)

def run_cppcheck(directory):
    buf = StringIO()
    try:
       sh.cppcheck(directory, _out=buf, _err_to_out=True)
    except sh.ErrorReturnCode_1 as e:
        pass
    return buf.getvalue()

def run_cppcheck_w_opt(directory, cmd_options)
    buf = StringIO()
    try:
        sh.cppcheck(options, directory, _out=buf, _err_to_out=True)

    return buf.getvalue()
