#!/bin/bash
virt_env=tiktok
env_type=${1}
conf_file=${2}
python_version=3.12.3

if [ "$(uname)" == "Darwin" ]
then
    conda_shell=/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh

    if [ "${CONDA_DEFAULT_ENV} " != "${virt_env} " ]
    then
        source ${conda_shell}
        if ! conda env list | grep ${virt_env} > /dev/null
        then
            conda create -n ${virt_env} python==${python_version} -y
        fi
        conda activate ${virt_env} || exit 1
    fi
elif [ "$(uname)" == "Linux" ]
then
    if [ ! -d "./${virt_env} " ]
    then
        python3 -m venv ${virt_env}
        source ${virt_env}/bin/activate
    elif [[ ! "${VIRTUAL_ENV} " == *"${virt_env} " ]]
    then
        source ${virt_env}/bin/activate
    fi
else
    echo "Env $(uname) not supported"
    exit 1
fi

pip install -r ./requirements.txt

exec_command=''


if [ ! -f ./.api_key ]
then
    echo "File .api_key missing"
else
    exec_command='SIGN_API_KEY=$(cat ./.api_key)'
fi

# Web UI credentials for Basic auth, see README.
# The environment wins, the .web_ui_auth file (one line, username:password) is the fallback.
if [ -z "${WEB_UI_USERNAME}" ] || [ -z "${WEB_UI_PASSWORD}" ]
then
    if [ -f ./.web_ui_auth ]
    then
        web_ui_cred=$(head -n 1 ./.web_ui_auth)
        case "${web_ui_cred}" in
            *:*)
                # only the first colon separates, so the password may contain colons
                WEB_UI_USERNAME="${web_ui_cred%%:*}"
                WEB_UI_PASSWORD="${web_ui_cred#*:}"
                export WEB_UI_USERNAME WEB_UI_PASSWORD
                ;;
            *)
                echo "WARNING: ./.web_ui_auth must contain one line of the form username:password, ignoring it"
                ;;
        esac
    fi
fi

if [ -z "${WEB_UI_USERNAME}" ] || [ -z "${WEB_UI_PASSWORD}" ]
then
    echo "WARNING: the Web UI on port 8000 will be UNAUTHENTICATED"
    echo "         set WEB_UI_USERNAME and WEB_UI_PASSWORD, or create a .web_ui_auth file"
else
    echo "Web UI protected with Basic auth, user: ${WEB_UI_USERNAME}"
fi

exec_command="${exec_command} python main.py"

if [ ! "${env_type} " == "PROD " ]
then
    exec_command="${exec_command} --test"
fi

exec_command="${exec_command} --config ${conf_file}"

echo "Executing ${exec_command}"

eval "${exec_command}"



