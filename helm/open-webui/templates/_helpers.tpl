{{- define "open-webui.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "open-webui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "ollama.name" -}}
open-webui-ollama
{{- end -}}

{{- define "pipelines.name" -}}
open-webui-pipelines
{{- end -}}

{{- define "ollamaUrls" -}}
{{- if .Values.ollamaUrls }}
{{- join ";" .Values.ollamaUrls | trimSuffix "/" }}
{{- end }}
{{- end }}

{{- define "ollamaLocalUrl" -}}
{{- if .Values.ollama.enabled -}}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $ollamaServicePort := .Values.ollama.service.port | toString }}
{{- printf "http://%s.%s.svc.%s:%s" (default .Values.ollama.name .Values.ollama.fullnameOverride) (.Release.Namespace) $clusterDomain $ollamaServicePort }}
{{- end }}
{{- end }}

{{- define "ollamaBaseUrls" -}}
{{- $ollamaLocalUrl := include "ollamaLocalUrl" . }}
{{- $ollamaUrls := include "ollamaUrls" . }}
{{- if and .Values.ollama.enabled .Values.ollamaUrls }}
{{- printf "%s;%s" $ollamaUrls $ollamaLocalUrl }}
{{- else if .Values.ollama.enabled }}
{{- printf "%s" $ollamaLocalUrl }}
{{- else if .Values.ollamaUrls }}
{{- printf "%s" $ollamaUrls }}
{{- end }}
{{- end }}

{{- define "chart.name" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "base.labels" -}}
helm.sh/chart: {{ include "chart.name" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "open-webui.name" . }}
{{- end }}

{{- define "base.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "open-webui.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ .Chart.Name }}
{{- end }}

{{- define "open-webui.extraLabels" -}}
{{- with .Values.extraLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{- define "open-webui.labels" -}}
{{ include "base.labels" . }}
{{ include "open-webui.selectorLabels" . }}
{{- end }}

{{- define "ollama.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "ollama.name" . }}
{{- end }}

{{- define "ollama.labels" -}}
{{ include "base.labels" . }}
{{ include "ollama.selectorLabels" . }}
{{- end }}

{{- define "pipelines.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ include "pipelines.name" . }}
{{- end }}

{{- define "pipelines.labels" -}}
{{ include "base.labels" . }}
{{ include "pipelines.selectorLabels" . }}
{{- end }}

{{- define "pipelines.serviceEndpoint" -}}
{{- if .Values.pipelines.enabled -}}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $pipelinesServicePort := .Values.pipelines.service.port | toString }}
{{- printf "http://%s.%s.svc.%s:%s" (include "pipelines.name" .) (.Release.Namespace) $clusterDomain $pipelinesServicePort }}
{{- end }}
{{- end }}

{{- define "websocket.redis.selectorLabels" -}}
{{ include "base.selectorLabels" . }}
app.kubernetes.io/component: {{ .Values.websocket.redis.name }}
{{- end }}

{{- define "websocket.redis.labels" -}}
{{ include "base.labels" . }}
{{ include "websocket.redis.selectorLabels" . }}
{{- end }}

{{- define "sso.validateClientSecret" -}}
{{- $provider := .provider }}
{{- $values := .values }}
{{- if and (empty (index $values $provider "clientSecret")) (empty (index $values $provider "clientExistingSecret")) }}
  {{- fail (printf "You must provide either .Values.sso.%s.clientSecret or .Values.sso.%s.clientExistingSecret" $provider $provider) }}
{{- end }}
{{- end }}

{{- define "logging.isValidComponent" -}}
  {{- $component := . | lower -}}
  {{- $validComponents := dict
      "audio" true
      "comfyui" true
      "config" true
      "db" true
      "images" true
      "main" true
      "models" true
      "ollama" true
      "openai" true
      "rag" true
      "webhook" true
  -}}
  {{- hasKey $validComponents $component -}}
{{- end }}

{{- define "logging.assertValidComponent" -}}
  {{- $component := lower . -}}
  {{- $res := include "logging.isValidComponent" $component }}
  {{- if ne $res "true" }}
    {{- fail (printf "Invalid logging component name: '%s'. Valid names: audio, comfyui, config, db, images, main, models, ollama, openai, rag, webhook" $component) }}
  {{- end }}
{{- end }}

{{- define "logging.assertValidLevel" -}}
  {{- $level := lower . }}
  {{- $validLevels := dict "notset" true "debug" true "info" true "warning" true "error" true "critical" true }}
  {{- if not (hasKey $validLevels $level) }}
    {{- fail (printf "Invalid log level: '%s'. Valid values are: notset, debug, info, warning, error, critical" $level) }}
  {{- end }}
{{- end }}

{{- define "logging.componentEnvVar" -}}
  {{- $name := .componentName }}
  {{- $level := .logLevel }}
{{- include "logging.assertValidComponent" $name -}}
{{- include "logging.assertValidLevel" $level }}
- name: {{ printf "%s_LOG_LEVEL" (upper $name) | quote }}
  value: {{ $level | quote | trim }}
{{- end }}

{{- define "open-webui.hasCustomWebUIUrl" -}}
  {{- $found := false -}}
  {{- $extra := .Values.extraEnvVars -}}
  {{- if kindIs "map" $extra }}
    {{- if hasKey $extra "WEBUI_URL" -}}
      {{- $found = true -}}
    {{- end -}}
  {{- else if kindIs "slice" $extra }}
    {{- range $extra }}
      {{- if eq .name "WEBUI_URL" }}
        {{- $found = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $found }}true{{- end -}}
{{- end -}}

{{- define "open-webui.url" -}}
  {{- $proto := "http" -}}
  {{- if .Values.ingress.tls }}
    {{- $proto = "https" -}}
  {{- end }}
  {{- printf "%s://%s" $proto .Values.ingress.host }}
{{- end }}

{{- define "open-webui.env" -}}
{{- if kindIs "map" . }}
  {{- range $key, $val := . }}
- name: {{ $key }}
    {{- if kindIs "map" $val }}
      {{- toYaml $val | nindent 2 }}
    {{- else }}
  value: {{ $val | quote }}
    {{- end }}
  {{- end }}
{{- else }}
  {{- toYaml . }}
{{- end }}
{{- end }}

{{- define "open-webui.tag" -}}
{{- $image := .Values.image }}
{{- if $image.tag }}

{{- $image.tag -}}
{{- else if $image.useSlim }}

{{- printf "%s-slim" .Chart.AppVersion -}}
{{- else }}

{{- .Chart.AppVersion -}}
{{- end }}
{{- end }}
