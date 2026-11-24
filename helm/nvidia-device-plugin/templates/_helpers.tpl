{{- define "nvidia-device-plugin.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nvidia-device-plugin.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "nvidia-device-plugin.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{- define "nvidia-device-plugin.chart" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" $name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nvidia-device-plugin.labels" -}}
helm.sh/chart: {{ include "nvidia-device-plugin.chart" . }}
{{ include "nvidia-device-plugin.templateLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "nvidia-device-plugin.templateLabels" -}}
app.kubernetes.io/name: {{ include "nvidia-device-plugin.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.selectorLabelsOverride }}
{{ toYaml .Values.selectorLabelsOverride }}
{{- end }}
{{- end }}

{{- define "nvidia-device-plugin.selectorLabels" -}}
{{- if .Values.selectorLabelsOverride -}}
{{ toYaml .Values.selectorLabelsOverride }}
{{- else -}}
{{ include "nvidia-device-plugin.templateLabels" . }}
{{- end }}
{{- end }}

{{- define "nvidia-device-plugin.fullimage" -}}
{{- $tag := printf "v%s" .Chart.AppVersion }}
{{- .Values.image.repository -}}:{{- .Values.image.tag | default $tag -}}
{{- end }}

{{- define "nvidia-device-plugin.securityContext" -}}
{{- if ne (len .Values.securityContext) 0 -}}
{{ toYaml .Values.securityContext }}
{{- else if .Values.compatWithCPUManager -}}
privileged: true
{{- else if eq (include "nvidia-device-plugin.requiresCapSysAdmin" .) "true" -}}
capabilities:
  add:
    - SYS_ADMIN
{{- else -}}
allowPrivilegeEscalation: false
capabilities:
  drop: ["ALL"]
{{- end -}}
{{- end -}}

{{- define "gpu-feature-discovery.securityContext" -}}
{{- if ne (len .Values.gfd.securityContext) 0 -}}
{{ toYaml .Values.gfd.securityContext }}
{{- else if eq (include "nvidia-device-plugin.requiresCapSysAdmin" .) "true" -}}
capabilities:
  add:
    - SYS_ADMIN
{{- else -}}
allowPrivilegeEscalation: false
capabilities:
  drop: ["ALL"]
{{- end -}}
{{- end -}}

{{- define "nvidia-device-plugin.requiresCapSysAdmin" -}}
{{- $result := false -}}
{{- if ne (include "nvidia-device-plugin.allPossibleMigStrategiesAreNone" .) "true" -}}
  {{- $result = true -}}
{{- else if eq (include "nvidia-device-plugin.deviceListStrategyIncludesVolumeMount" .) "true" -}}
  {{- $result = true -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{- define "nvidia-device-plugin.allPossibleMigStrategiesAreNone" -}}
{{- $result := true -}}
{{- if .Values.migStrategy -}}
  {{- if ne .Values.migStrategy "none" -}}
    {{- $result = false -}}
  {{- end -}}
{{- else if eq (include "nvidia-device-plugin.hasConfigMap" .) "true" -}}
    {{- $result = false -}}
{{- else -}}
  {{- range $name, $contents := $.Values.config.map -}}
    {{- $config := $contents | fromYaml -}}
    {{- if $config.flags -}}
      {{- if ne $config.flags.migStrategy "none" -}}
        {{- $result = false -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{- define "nvidia-device-plugin.deviceListStrategyIncludesVolumeMount" -}}
{{- $result := false -}}
{{- if .Values.deviceListStrategy -}}
  {{- $result = ( contains "volume-mounts" .Values.deviceListStrategy ) -}}
{{- else if eq (include "nvidia-device-plugin.hasConfigMap" .) "true" -}}
    {{- $result = true -}}
{{- else -}}
  {{- range $name, $contents := $.Values.config.map -}}
    {{- $config := $contents | fromYaml -}}
    {{- if $config.flags -}}
      {{- if $config.flags.plugin -}}
        {{- if typeIs "string" $config.flags.plugin.deviceListStrategy }}
          {{- $result = ( contains "volume-mounts" $config.flags.plugin.deviceListStrategy ) -}}
        {{- else if typeIs "list" $config.flags.plugin.deviceListStrategy }}
          {{- $result = ( has "volume-mounts" $config.flags.plugin.deviceListStrategy ) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{- define "nvidia-device-plugin.hasEmbeddedConfigMap" -}}
{{- $result := true -}}
{{- if empty .Values.config.map  -}}
  {{- $result = false -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{- define "nvidia-device-plugin.hasConfigMap" -}}
{{- $result := false -}}
{{- if ne (include "nvidia-device-plugin.configMapName" .) "" -}}
  {{- $result = true -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{- define "nvidia-device-plugin.hasDefaultConfig" -}}
{{- $result := "false" -}}
{{- if .Values.config.default -}}
  {{- $result = "true"  -}}
{{- else if not (empty .Values.config.map) -}}
  {{- if has "named" .Values.config.fallbackStrategies -}}
    {{- if hasKey .Values.config.map "default" -}}
      {{- $result = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- if has "single" .Values.config.fallbackStrategies -}}
    {{- if eq (.Values.config.map | keys | len) 1 -}}
      {{- $result = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- if has "empty" .Values.config.fallbackStrategies -}}
    {{- $result = "true" -}}
  {{- end -}}
{{- end -}}
{{- $result -}}
{{- end }}

{{- define "nvidia-device-plugin.configMapName" -}}
{{- $result := "" -}}
{{- if .Values.config.name -}}
  {{- $result = .Values.config.name -}}
{{- else if not (empty .Values.config.map) -}}
  {{- $result = printf "%s-%s" (include "nvidia-device-plugin.fullname" .) "configs" -}}
{{- end -}}
{{- $result -}}
{{- end -}}

{{- define "nvidia-device-plugin.podAnnotations" -}}
{{- $annotations := deepCopy .local.Values.podAnnotations -}}
{{- if not (hasKey $annotations "checksum/config") -}}
  {{- if eq (include "nvidia-device-plugin.hasEmbeddedConfigMap" .root) "true" -}}
    {{- $_ := set $annotations "checksum/config" (include (print $.root.Template.BasePath "/configmap.yaml") .root | sha256sum) -}}
  {{- end -}}
{{- end -}}
{{- toYaml $annotations }}
{{- end -}}

{{- define "nvidia-device-plugin.options" -}}
{{- $options := dict "" "" -}}
{{- $_ := set $options "hasConfigMap" ( eq ( (include "nvidia-device-plugin.hasConfigMap" . ) | trim ) "true" ) -}}
{{- $_ := set $options "addMigMonitorDevices" ( ne ( (include "nvidia-device-plugin.allPossibleMigStrategiesAreNone" . ) | trim ) "true" )  -}}
{{- mustToJson $options -}}
{{- end -}}
