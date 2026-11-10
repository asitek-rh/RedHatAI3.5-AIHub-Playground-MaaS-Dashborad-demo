# Model Deployment via RHOAI Dashboard

Both models must be deployed via the RHOAI GUI with these exact settings.

## gpt-oss-20b

1. RHOAI Dashboard → Models as a Service → Deploy model
2. **Model details**:
   - Type: Generative AI model
   - Location: URI
   - URI: `oci://registry.redhat.io/rhelai1/modelcar-gpt-oss-20b:1.5`
3. **Model deployment**:
   - Project: `models-as-a-service`
   - Name: `RedHatAI/gpt-oss-20b`
   - Hardware profile: `gpu-l4-nvidia`
   - Format: vLLM
   - Replicas: 1
   - Accelerator: vLLM NVIDIA CUDA GPU LLMInferenceServiceConfig Single Node
4. **Advanced settings**:
   - Add as AI asset endpoint: ✅
   - Use case: `chat`
   - Publish as MaaS: ✅
   - Gateway: `maas-default-gateway | openshift-ingress`
   - Token authentication: greyed out (MaaS handles it)
   - Custom runtime arguments:
     ```
     --enable-auto-tool-choice
     --tool-call-parser
     openai
     ```

## qwen3-8b-fp8

1. RHOAI Dashboard → Models as a Service → Deploy model
2. **Model details**:
   - URI: `oci://registry.redhat.io/rhelai1/modelcar-qwen3-8b-fp8-dynamic:1.5`
3. **Model deployment**:
   - Project: `models-as-a-service`
   - Name: `RedHatAI/Qwen3-8B-FP8-dynamic`
   - Hardware profile: `gpu-l4-nvidia`
   - Format: vLLM
   - Replicas: 1
   - Accelerator: vLLM NVIDIA CUDA GPU LLMInferenceServiceConfig Single Node
4. **Advanced settings**:
   - Add as AI asset endpoint: ✅
   - Use case: `chat on playground`
   - Publish as MaaS: ✅
   - Gateway: `maas-default-gateway | openshift-ingress`
   - Custom runtime arguments:
     ```
     --enable-auto-tool-choice
     --tool-call-parser
     hermes
     ```

## After deployment

Wait for both models to show **Ready** status before proceeding to Step 3.
