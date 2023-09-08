{{- define "mongodb.serviceName" -}}
{{ .Release.Name }}-mongo-service
{{- end -}}