# Maybank technical test 
---

## Prerequisite 

- Kubectl client v1.29.2
- Terraform client v1.6.1

## Steps for question 1

1. Navigate to the `question_1` directory:
    ```sh
    cd question_1
    ```
2. Install the required dependencies:
    ```sh
    terraform init
    ```
3. Run the tf plan:
    ```sh
    terraform plan
    ```

## Steps for question 2

1. Navigate to the `question_1` directory:
    ```sh
    cd question_2
    ```
2. Run dry run kubectl manifest:
    ```sh
    kubectl apply --dry-run=client -f solution.yaml
    ```