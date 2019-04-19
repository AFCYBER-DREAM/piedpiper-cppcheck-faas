import os
import sh
from io import StringIO
from .util import unzip_files
import yaml
import tempfile


def handle(request):
    """handle a request to the function
    Args:
        req (str): request body
    """

    zip_file = request.files.getlist('files')[0]
    cppcheck_reports = []

    with tempfile.TemporaryDirectory() as tmpdir:
        unzip_files(zip_file, tmpdir)
        os.chdir(tmpdir)

        project_directories = [
            name
            for name in os.listdir(".")
            if os.path.isdir(name)
        ]
        for project_directory in project_directories:
            try:
                with open(f'{tmpdir}/{project_directory}/run_vars.yml', 'r') as o:
                    run_vars = yaml.safe_load(o)
                    if run_vars.get('options') is None:
                        cppcheck_reports.append(
                            "Empty options found in run_vars.yml, resorting to defaults"
                        )
                        report = run_cppcheck(project_directory)
                        cppcheck_reports.append(report)
                    else:
                        report = run_cppcheck(
                            project_directory,
                            options=run_vars['options']
                        )
                        cppcheck_reports.append(report)
            except FileNotFoundError:
                cppcheck_reports.append(
                    f"Unable to open {tmpdir}/{project_directory}/run_vars.yml \n"
                )
    return '\n'.join(cppcheck_reports)


def run_cppcheck(project_directory, options=False):
    cmd_options = [
        '--force',
        '--enable=all',
        project_directory,
    ]
    if options:
        cmd_options.extend(options)
    buf = StringIO()
    try:
        sh.cppcheck(list(dict.fromkeys(cmd_options)), _out=buf, _err_to_out=True)
    except sh.ErrorReturnCode_1:
        pass
    return buf.getvalue()
