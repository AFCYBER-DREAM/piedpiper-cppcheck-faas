#!/bin/bash


## Supress output from pushd and popd
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

project='cpp_project'

expected=(
    "Empty options found in run_vars.yml, resorting to defaults"
    "Checking cpp_project/src/chrome_content_renderer_client.cc ..."
    "[cpp_project/src/chrome_content_renderer_client.cc:871] -> [cpp_project/src/chrome_content_renderer_client.cc:874]: (style) Local variable 'i' shadows outer variable"
    "[cpp_project/src/chrome_content_renderer_client.cc:1031]: (style) Variable 'failed_url' is assigned a value that is never used."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: DISABLE_NACL..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: DISABLE_NACL;ENABLE_EXTENSIONS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: DISABLE_NACL;ENABLE_EXTENSIONS;ENABLE_PLUGINS..."
    "[cpp_project/src/chrome_content_renderer_client.cc:633] -> [cpp_project/src/chrome_content_renderer_client.cc:683]: (style) Local variable 'info' shadows outer variable"
    "[cpp_project/src/chrome_content_renderer_client.cc:636] -> [cpp_project/src/chrome_content_renderer_client.cc:684]: (style) Local variable 'identifier' shadows outer variable"
    "Checking cpp_project/src/chrome_content_renderer_client.cc: DISABLE_NACL;ENABLE_EXTENSIONS;ENABLE_PLUGINS;OS_CHROMEOS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: DISABLE_NACL;ENABLE_PLUGINS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_EXTENSIONS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_EXTENSIONS;ENABLE_PLUGINS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_IPC_FUZZER..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_PEPPER_CDMS;WIDEVINE_CDM_AVAILABLE;ENABLE_PLUGINS..."
    "[cpp_project/src/chrome_content_renderer_client.cc:933] -> [cpp_project/src/chrome_content_renderer_client.cc:932] -> [cpp_project/src/chrome_content_renderer_client.cc:964]: (style) Same expression on both sides of '||' because 'is_extension_force_installed' and 'is_extension_unrestricted' represent the same value."
    "[cpp_project/src/chrome_content_renderer_client.cc:931] -> [cpp_project/src/chrome_content_renderer_client.cc:933] -> [cpp_project/src/chrome_content_renderer_client.cc:965]: (style) Same expression on both sides of '||' because 'is_invoked_by_webstore_installed_extension' and 'is_extension_force_installed' represent the same value."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_PLUGINS..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_PLUGINS;ENABLE_PLUGIN_INSTALLATION..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_PRINTING..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_PRINT_PREVIEW..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_SPELLCHECK..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: ENABLE_WEBRTC..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: FULL_SAFE_BROWSING..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: OS_ANDROID..."
    "Checking cpp_project/src/chrome_content_renderer_client.cc: OS_CHROMEOS..."
    "1/2 files checked 44% done"
    "Checking cpp_project/src/io_thread.cc ..."
    "Checking cpp_project/src/io_thread.cc: ARCH_CPU_ARMEL;OS_ANDROID..."
    "Checking cpp_project/src/io_thread.cc: DISABLE_FTP_SUPPORT..."
    "Checking cpp_project/src/io_thread.cc: ENABLE_EXTENSIONS..."
    "Checking cpp_project/src/io_thread.cc: OS_ANDROID..."
    "Checking cpp_project/src/io_thread.cc: OS_ANDROID;OS_POSIX..."
    "Checking cpp_project/src/io_thread.cc: OS_CHROMEOS..."
    "Checking cpp_project/src/io_thread.cc: OS_MACOSX..."
    "Checking cpp_project/src/io_thread.cc: OS_WIN..."
    "Checking cpp_project/src/io_thread.cc: USE_NSS_CERTS..."
    "2/2 files checked 100% done"
    "[cpp_project/src/io_thread.cc:403]: (style) The function 'GetNetworkTaskRunner' is never used."
    "[cpp_project/src/io_thread.cc:395]: (style) The function 'GetURLRequestContext' is never used."
    "[cpp_project/src/io_thread.cc:336]: (style) The function 'OnConnectionTypeChanged' is never used."
    "[cpp_project/src/io_thread.cc:329]: (style) The function 'OnIPAddressChanged' is never used."
    "[cpp_project/src/io_thread.cc:350]: (style) The function 'OnNetworkChanged' is never used."
    "[cpp_project/src/chrome_content_renderer_client.cc:266]: (style) The function 'Visit' is never used."
    "[cpp_project/src/chrome_content_renderer_client.cc:293]: (style) The function 'WasShown' is never used."
    "(information) Cppcheck cannot find all the include files (use --check-config for details)"
)

errors=0
echo "Running tests on project $project in $(dirname $0)/$project"
pushd $(dirname $0)
if [[ -f "${project}.zip" ]]; then
  echo "Removing leftover zipfile ${project}.zip"
  rm -f "${project}.zip"
fi
zip -qr "${project}".zip $project/*
results=$(curl -s -F "files=@${project}.zip" http://127.0.0.1:8080/function/piedpiper-cppcheck-function)
while read -r line ; do
  found=false
  for i in "${!expected[@]}"; do
    if [[ "${line}" == "${expected[i]}" ]]; then
	  unset 'expected[i]'
	  found=true
	fi
  done
  if [[ "${found}" == false ]]; then
    echo "Match not found for line ${line}"
	errors=$((errors+1))
  fi
done <<< "${results}"
if [[ "${#expected[@]}" -ne 0 ]]; then
  echo "Not all expected results found. ${#expected[@]} leftover"
  for line in "${expected[@]}"; do
    echo "Not found: "
	echo "${line}"
  done
  errors=$((errors+1))
fi
if [[ -f "${project}.zip" ]]; then
  echo "Removing leftover zipfile ${project}.zip"
  rm -f "${project}.zip"
fi
popd


if [[ "${errors}" == 0 ]]; then
    echo "Test ran successfully";
    exit 0;
else
    echo "Test failed";
	exit 1;
fi
