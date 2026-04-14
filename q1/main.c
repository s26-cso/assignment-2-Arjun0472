#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);

int main(void) {
    struct Node* root = NULL;
    char cmd[32];
    int val;

    printf("insert value\nget value\natmost value\nquit\n");
    printf("\n");
    while (1) {
        scanf("%s", cmd);

        if (strcmp(cmd, "insert") == 0) {
            scanf("%d", &val);
            root = insert(root, val);
            printf("inserted %d\n", val);
        } 
        else if (strcmp(cmd, "get") == 0) {
            scanf("%d", &val);
            struct Node* found = get(root, val);
            printf("%p\n", found);
        } 
        else if (strcmp(cmd, "atmost") == 0) {
            scanf("%d", &val);
            int result = getAtMost(val, root);
            if (result == -1)
                printf("no value less than or equal to %d found\n", val);
            else
                printf("greatest value less than or equal to %d is %d\n", val, result);
        } 
        else if (strcmp(cmd, "quit") == 0)
            break;
    }
    return 0;
}
