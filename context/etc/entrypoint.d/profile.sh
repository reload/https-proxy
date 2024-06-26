#!/usr/bin/env bash

if [ -r "/etc/nginx/profiles/${PROFILE}.conf.template" ]; then
	ln -s "/etc/nginx/profiles/${PROFILE}.conf.template" "/etc/nginx/templates/${PROFILE}.conf.template"
fi
