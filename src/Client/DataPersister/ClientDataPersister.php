<?php

namespace App\Client\DataPersister;

use ApiPlatform\Core\DataPersister\ContextAwareDataPersisterInterface;
use App\Entity\Client;
use Doctrine\Persistence\ManagerRegistry;
use Exception;

final class ClientDataPersister implements ContextAwareDataPersisterInterface
{
    private ContextAwareDataPersisterInterface $decorated;
    private ManagerRegistry $doctrine;

    public function __construct(
        ContextAwareDataPersisterInterface $decorated,
        ManagerRegistry $doctrine,

    ) {
        $this->decorated = $decorated;
        $this->doctrine = $doctrine;
    }
    
    public function supports($data, array $context = []): bool
    {
        return $data instanceof Client && $this->decorated->supports($data, $context);
    }

    /**
     * @throws Exception
     */
    public function persist($data, array $context = [])
    {
        if($data instanceof Client){
            $email = $data->getEmail();
            $entityManager = $this->doctrine->getManager();
            $client = $entityManager->getRepository(Client::class)->findOneBy(['email' => $email]);

            if (!$client) {
                return $this->decorated->persist($data, $context);
            }
            throw new Exception('Client already exists !',403);
        }
        throw new Exception('invalid parameters !',500);
    }

    public function remove($data, array $context = [])
    {
    }
}
