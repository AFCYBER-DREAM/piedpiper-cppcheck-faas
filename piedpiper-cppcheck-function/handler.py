import os
import sh
from io import StringIO
from .util import unzip_files
import yaml 
from pathlib import Path
import tempfile


def handle(zip_file):
    """handle a request to the function
    Args:
        req (str): request body
    """
    cppcheck_reports = []
    
    with tempfile.TemporaryDirectory() as tmpdir: 
        unzip_files(zip_file, tmpdir)
        os.chdir(tmpdir)

        #verify that run_vars.yml is found
        if(os.path.exists(f'{tmpdir}/run_vars.yml')):
            with open(f'{tmpdir}/run_vars.yml', 'r') as o:
                try:
                    #attempt to load run_vars.yml
                    run_vars = yaml.safe_load(o)
                    if run_vars is None or run_vars['options'] is None:    #null value 
                        cppcheck_reports.append("Nothing found in run_vars.yml, resorting to defaults")
                        report = run_cppcheck(".")
                    else:   
                        report = run_cppcheck(run_vars['options'])    
                except:
                    #error encountered opening run_vars.yml
                    cppcheck_reports.append(f"Unable to open {tmpdir}/run_vars \n")
                    sys.exit(0)
        else:
            cppcheck_reports.append(f"Unable to locate {tmpdir}/run_vars \n")
            sys.exit(0)
        cppcheck_reports.append(report)
    return '\n'.join(cppcheck_reports)

def run_cppcheck(cmd_options ):
    buf = StringIO()
 
    try:
        sh.cppcheck(cmd_options, _out=buf, _err_to_out=True)
    except sh.ErrorReturnCode_1 as e:
        print (e)
        pass
    return buf.getvalue()
