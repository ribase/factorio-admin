<?php

namespace Ribase\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;

class WaitController extends Controller
{

    /**
     * @Route("/wait", name="Wait")
     */
    public function listAction(Request $request)
    {
        $int = rand(1,5);
        sleep(4);
        return $this->render('admin/serverlogs.html.twig', array(
            'view' => $int,
        ));
    }
}