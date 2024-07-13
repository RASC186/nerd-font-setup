#!/usr/bin/env bash

echo -e "\n\033[32mNerd-Font Installer\033[0m\n"

echo -e "Scanning /ryanoasis/nerd-fonts repo..."

readarray -t endpoints 	< \
 	<(curl -s 'https://github.com/ryanoasis/nerd-fonts/releases' |\
  grep -oP '\"/ryanoasis/nerd-fonts/releases/tag/[\w\d\/\.]+\"')

if [[ -z ${endpoints[*]} ]] ; then
  echo -e "\033[0;31mLatest version not found.\033[0m"
  exit 
else
  latest_version="$(echo "${endpoints[0]}" | grep -oP '(?<=tag/)v[\d\.]+')"
  echo -e "Latest version found: ${latest_version}"
fi

echo -e "Getting nerd fonts download links..."

readarray -t download_links < \
	<(curl -s "https://github.com/ryanoasis/nerd-fonts/releases/expanded_assets/${latest_version}" |\
  grep -oP "\"/ryanoasis/nerd-fonts/releases/download/${latest_version}/[\\w\\d\\.]+\"")

if [[ -z ${download_links[*]} ]] ; then
  echo -e "\033[0;31mLinks not found.\033[0m"
  exit
else
  echo "Fonts found:"
fi

declare -A fonts
for link in "${download_links[@]}" ; do
	font_name=$(echo "${link}" | grep -oP '(?<=/)[\w\d]+(?=\.[\w\d\.]+")')
	fonts["${font_name}"]="$(echo "${link}" | tr -d '"')"
done

keys=${!fonts[*]}
sorted_keys=$(echo -e "${keys// /\\n}" | sort)

PS3="Insert font number: "
select font in ${sorted_keys} ; do
	
	if [[ -z "${fonts[${font}]}" ]] ; then
		echo -e "\033[0;31mInvalid input!\033[0m"
	else	
	  selected_font="https://github.com${fonts[${font}]}"
    break
	fi

done

downloads_dirpath="/tmp/nvim-nerdfonts/"
compacted_filename="$(echo "${selected_font}" | grep -oP '(?<=/)[\w\d\.]+(?=$)')"
compacted_filepath="${downloads_dirpath}${compacted_filename}"

echo -e "Downloading ${selected_font}..."

mkdir "${downloads_dirpath}"
wget_error="$(wget -O "${compacted_filepath}" "${selected_font}" 2>&1 | grep -oP 'ERROR[\s\S]+')"
wait $!

if [[ ${wget_error} ]] ; then
  echo -e "\033[0;31mDownload failed! ${wget_error}\033[0m"
  exit
fi

compacted_file_extention="$(echo "${selected_font}" | grep -oP '(?<=\.)[\w\d\.]+(?=$)')"
fonts_dirpath="${HOME}/.local/share/fonts/$(echo "${compacted_filename}" | grep -oP '[\w\d]+(?=\.)')"

mkdir "${HOME}/.local/share/fonts/"

if [[ ${compacted_file_extention} = 'tar' ]] ; then
	tar -xf "${compacted_filepath}" -C "${fonts_dirpath}"
elif [[ ${compacted_file_extention} = 'tar.'* ]] ; then
	tar -xf "${compacted_filepath}" -C "${fonts_dirpath}"
elif [[ ${compacted_file_extention} = 'zip' ]] ; then
	unzip "${compacted_filepath}" -d "${fonts_dirpath}"
fi
