#!/bin/bash

# Catch the required parameters
while getopts 'B:T:R:P:' OPTION; do
 case "$OPTION" in
  B)
   baseimageName="$OPTARG"
   echo $baseimageName
   ;;

  T)
   baseimageTag="$OPTARG"
   echo $baseimageTag
   ;;

  R)
   output_image_name="$OPTARG"
   echo $output_image_name
   ;;

   P)
   file_path="$OPTARG"
   echo $file_path
   ;;

  ?)
   echo "ERROR: Wrong Execution"
   echo "script usage: taginherit.sh [-B Base Image Name] [-T Base Image Tag] [-R Result Image Name]" >&2
   exit 1
   ;;

 esac
done

# Determine if the base image used in the project corresponds to one of the Standarized

valid_images_id=('base_image')

for i in ${valid_images_id[@]}
do
    if [ $i = $baseimageName ]; then
	# Determine the tags of the base image
	baseimageID="$baseimageName"':'"$baseimageTag"
	echo $baseimageID
	base_image_tags=$(docker image inspect --format='{{join .RepoTags "\n"}}' $baseimageID)
	base_image_name=$(echo ${base_image_tags[0]} | cut -d ':' -f1)
	echo $base_image_name
	# Build the new image
    echo ${file_path}/Dockerfile
	docker build --build-arg IMAGE_NAME=$base_image_name --build-arg IMAGE_TAG=$baseimageTag -t $output_image_name -f Dockerfile ${file_path}

	# Assing taf to the image
	for tag in $base_image_tags
	do
 	 separate_tag=(${tag//:/ })
 	 #echo ${separate_tag[1]}
 	 docker tag $output_image_name:latest $output_image_name:${separate_tag[1]}
	done
	break
    fi
done
