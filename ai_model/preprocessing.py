"""
SmartCrop AI — Image Preprocessing
====================================
Transforms for training (with augmentation) and
validation/test (clean). Uses ImageNet normalization
compatible with MobileViT pretrained weights.
"""

from torchvision import transforms
from config import IMAGE_SIZE, IMAGENET_MEAN, IMAGENET_STD, AUGMENTATION


def get_train_transforms():
    """Training transforms with data augmentation."""
    transform_list = []

    # Random resized crop
    transform_list.append(
        transforms.RandomResizedCrop(
            IMAGE_SIZE,
            scale=AUGMENTATION["random_resized_crop_scale"],
        )
    )

    # Random horizontal flip
    if AUGMENTATION["horizontal_flip"]:
        transform_list.append(transforms.RandomHorizontalFlip(p=0.5))

    # Random vertical flip
    if AUGMENTATION["vertical_flip"]:
        transform_list.append(transforms.RandomVerticalFlip(p=0.5))

    # Random rotation
    if AUGMENTATION["rotation_degrees"] > 0:
        transform_list.append(
            transforms.RandomRotation(AUGMENTATION["rotation_degrees"])
        )

    # Color jitter
    cj = AUGMENTATION["color_jitter"]
    transform_list.append(
        transforms.ColorJitter(
            brightness=cj["brightness"],
            contrast=cj["contrast"],
            saturation=cj["saturation"],
            hue=cj["hue"],
        )
    )

    # Convert to tensor and normalize
    transform_list.extend([
        transforms.ToTensor(),
        transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
    ])

    return transforms.Compose(transform_list)


def get_eval_transforms():
    """Validation/test transforms — no augmentation."""
    return transforms.Compose([
        transforms.Resize(int(IMAGE_SIZE * 1.1)),  # Slight oversize
        transforms.CenterCrop(IMAGE_SIZE),          # Then center crop
        transforms.ToTensor(),
        transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
    ])


def get_inference_transforms():
    """
    Inference transforms for single images from the API.
    Same as eval transforms but accepts PIL Image or numpy array.
    """
    return get_eval_transforms()
