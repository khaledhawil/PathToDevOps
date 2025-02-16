```yaml
global:
route:
  receiver: 'default'
  group_wait: 10s
  group_interval: 15s
  routes:
    - match:
        severity: 'HighCPULoad
      receiver: 'HighCPU'
    - match:
        node: 'node_exporter'
      receiver: 'Node_down'


- name: 'HighCPU'
  slack_configs:
  - channel: "#default"
    send_resolved: true
    api_url: 'https://hooks.slack.com/services/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'

- name: 'Node_down'
  email_configs:
  - to: khaledhawil91@gmail.com
    from: khaledhawil91@gmail.com
    smarthost: smtp.gmail.com:587
    auth_username: khaledhawil91@gmail.com
    auth_identity: khaledhawil91@gmail.com
    auth_password: ynjr tdhf nvmi cpkm
    send_resolved: true
```
